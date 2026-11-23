################################################################################
#
## -----------------------------------------------------------------------------
## HEADER_MSG    Generate uvm register model script
## HEADER_MSG    Author: MR Wang
################################################################################

import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
import sys
import argparse
import getopt
import openpyxl
import csv
import re

reg_pattern=".*REG_[0-9]+.*"
def derive_reg_width(records):
    """Widest register width in bits over the whole table. Per register both the
    field top bit (BitEnd+1, fields may span many rows) and the byte span
    ((EndAddr-OffsetAddr+1)*8) count; uvm_reg_data_t must hold the register."""
    def num(t, base=10):
        t = t.strip()
        if not t:
            return None
        try:
            return int(t, base)
        except ValueError:
            try:
                return int(t, 16)
            except ValueError:
                return None
    hdr = records[0]
    col = {}
    for i, name in enumerate(hdr):
        col[name] = i
    need = ("RegName", "FieldName", "OffsetAddr", "EndAddr", "BitEnd")
    if any(k not in col for k in need):
        return 0
    regs = {}
    import re as _re
    for row in records[1:]:
        if len(row) <= max(col[k] for k in need):
            continue
        reg = row[col["RegName"]].strip()
        if not reg:
            continue
        w = regs.get(reg, 0)
        m_lbl = _re.match(r"REG_(\d+)$", row[col["Label"]].strip())
        if m_lbl:
            w = max(w, int(m_lbl.group(1)))
        if row[col["FieldName"]].strip():
            be = num(row[col["BitEnd"]])
            if be is not None:
                w = max(w, be + 1)
        oa = num(row[col["OffsetAddr"]], 16)
        ea = num(row[col["EndAddr"]], 16)
        if oa is not None and ea is not None:
            w = max(w, (ea - oa + 1) * 8)
        regs[reg] = w
    return max(regs.values()) if regs else 0


def getparse():
    parser = argparse.ArgumentParser(description="input and output file about register model")
    parser.add_argument('-i','--input_reg_table',help='please input the reg_sfr_table, the format is xxx.xlsx',required=True, default='NO_Reg_Sfr_Tabel')
    parser.add_argument('-cov','--input_coverage_type',help='please input the collect coverage_type, the format is addr or field',required=True, default='NO_Cov_Type')
    parser.add_argument('-o','--output_regmdl_file',help='there is no define uvm register model name',required=True, default='NO_Uvm_Register_model')
    args = parser.parse_args()
    return args


class Col_title_template(object):
    def __init__(self):
        self.block_name        = "BlockName"
        self.label             = "Label"
        self.reg_name          = "RegName"
        self.field_name        = "FieldName"
        self.address           = "BaseAddr"
        self.offset_addr       = "OffsetAddr"
        self.end_addr         = "EndAddr"
        self.reset_value       = "ResetValue"
        self.bit_start         = "BitStart"
        self.bit_end           = "BitEnd"
        self.virtual_type      = "VirtualType"
        self.has_reset         = "Has_Reset"
        self.reset_source0     = "ResetSource"
        self.reset_source1     = "ResetSource1"
        self.hdlpath           = "HdlPath"
        self.regslicename      = "RegSliceName"

class Field(object):
    def __init__(self):
        self.row            = None
        self.name           = None
        self.reg            = None
        self.bit_start      = None
        self.bit_end        = None
        self.bitwidth       = None
        self.virtual_type   = None
        self.reset_value    = None
        self.has_reset      = None
        self.reset_source0  = None
        self.reset_source1  = None
        self.hdlpath        = None
        self.regslicename   = None

    def build_text(self):
        field_build      = "\t\t" + self.name + " = uvm_base_field::type_id::create(\"" + self.name + "\");\n"
        field_build     += "\t\t" + self.name + ".configure(this, " + str(self.bitwidth) + ", " + str(self.bit_start) + ", \"" + self.virtual_type + "\"" + ", 0, " + self.reset_value +", " +str(self.has_reset)+ ", 1, 1);\n"
        field_build     += "\t\t" + "if(" + self.name + ".has_reset() == 1) begin\n"
        field_build     += "\t\t\t\t" + self.name + ".set_reset_source0(\"" + str(self.reset_source0) + "\");\n"
        field_build     += "\t\t\t\t" + self.name + ".set_reset_source1(\"" + str(self.reset_source1) + "\");\n"
        field_build     += "\t\t" + "end"
        return field_build
    
    def rand_text(self):
        field_rand       = "\trand uvm_base_field " + self.name + ";"

        return field_rand

    def coverage_text(self):
        #width = int(self.bi)
        if self.bitwidth < 33 :
            #if self.virtual == 'RO':
                #coverage_text   = "\t\t" + self.name + ": coverpoint {m_data[" + self.bit_end + ":" + self.bit_start + "], m_is_read} iff(m_be) {"
                #coverage_text  += "\t\t\t" + "wildcard bins bit" +self.name + ": coverpoint {m_data[" + self.bit_end + ":" + self.bit_start + "], m_is_read} iff(m_be) {"
            coverage_text = self.wildcard_text(self.bitwidth, self.virtual_type)
        else:
            coverage_text  = self.auto_bins_text()
        return coverage_text

    def wildcard_text(self, width, is_ro):
        wildcard_text = "\n"
        width_d  = width +1
        wildcard_text   = "\t\t" + self.name + ": coverpoint {m_data[" + str(self.bit_end) + ":" + str(self.bit_start) + "], m_is_read} iff(m_be) {\n"
        if self.name[0:3] == 'rfu':
            for i in range(width):
                wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_rd_as_0 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "0" + "?"*(i) + "1};\n"
            wildcard_text  += "\t\t\toption.weight = " + str(width*3) + ";" + "\n"      
        else :
            if (is_ro == 'RW') | (is_ro ==  'W1C'):
                for i in range(width):
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_wr_as_0 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "0" + "?"*(i) + "0};\n"
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_wr_as_1 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "1" + "?"*(i) + "0};\n"
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_rd_as_0 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "0" + "?"*(i) + "1};\n"
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_rd_as_1 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "1" + "?"*(i) + "1};\n"
                wildcard_text  += "\t\t\toption.weight = " + str(width*4) + ";" + "\n"
            elif (is_ro == 'W1T')| (is_ro == 'RC'):
                for i in range(width):
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_wr_as_1 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "1" + "?"*(i) + "0};\n"
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_wr_as_0 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "0" + "?"*(i) + "0};\n"
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_rd_as_0 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "0" + "?"*(i) + "1};\n"
                wildcard_text  += "\t\t\toption.weight = " + str(width*3) + ";" + "\n"      
            else:
                for i in range(width):
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_rd_as_0 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "0" + "?"*(i) + "1};\n"
                    wildcard_text  += "\t\t\t" + "wildcard bins bit_" + str(i) + "_rd_as_1 = {" + str(width_d) + "\'b" + "?"*(width-1-i) + "1" + "?"*(i) + "1};\n"	
                wildcard_text  += "\t\t\toption.weight = " + str(width*2) + ";" + "\n"
        wildcard_text  += "\t\t}\n"        				
        #wildcard_text  += "option.weigth = " 
        return wildcard_text

    def auto_bins_text(self):
        auto_bins_text = "\n"
        auto_bins_text   = "\t\t" + self.name + ": coverpoint {m_data[" + str(self.bit_end) + ":" + str(self.bit_start) + "], m_is_read} iff(m_be) {\n"
        auto_bins_text  += "\t\t\toption.auto_bin_max=3;\n"
        auto_bins_text  += "\t\t}\n"        				
        #auto_bins_text  += "option.weigth = " 
        return auto_bins_text

class Register(object):
    def __init__(self):
        self.row            = None
        self.name           = None
        self.block          = None
        self.width          = None
        self.reg_endaddr    = None
        self.address        = None
        self.reset_value    = None
        self.rst_fd_num     = 0
        self.virtual_type	  = None
        self.hdlpath        = None
        self.field_list     = []
        self.has_real_field = None
        self.cov_type       = None

    def new_text(self):
        new_text     = "\t" + "function new(string name=\"" + self.name + "\");\n"
        new_text    += "\t\t" + "super.new(name, " + self.width + ", UVM_CVR_REG_BITS);\n"
        if reg.cov_type == 'cov_type':
            new_text    += "\t\t" + "if(has_coverage(UVM_CVR_REG_BITS))\n"
            new_text    += "\t\t\t" + "cg_bits = new();\n" 
        for field in self.field_list:
            if field.has_reset == 1:
                self.rst_fd_num += 1
        new_text    += "\t\t" + "rst_fd_num = 'd" + str(self.rst_fd_num) + ";\n"
        new_text    += "\t" + "endfunction : new\n"

        return new_text
    
    def rand_text(self):
        reg_rand_text = "\n"
        reg_rand_text += "\tlocal uvm_reg_data_t m_data;\n" 
        reg_rand_text += "\tlocal uvm_reg_data_t m_be;\n"
        reg_rand_text += "\tlocal bit            m_is_read;\n"
        reg_rand_text += "\tlocal int            rst_fd_num;\n"

        for field in self.field_list:
            reg_rand_text   += field.rand_text() + "\n"

        return reg_rand_text

    def build_text(self):
        reg_build_text = "\tvirtual function void build();\n"
        for field in self.field_list:
            reg_build_text  += field.build_text() + "\n"
        reg_build_text += "\t" + "endfunction\n"

        return reg_build_text

    def reg_text(self):
        reg_rand_text   =   self.rand_text()
        reg_build_text  =   self.build_text()
        reg_new_text    =   self.new_text()
        reg_coverage_text = self.coverage_text()
        reg_sample_text  = self.sample_text()

        reg_text     = 'class ' + self.name + " extends uvm_base_reg;\n"
        reg_text    += "\t`uvm_object_utils(" + self.name + ")\n"
        #reg_text    += "\t`uvm_register(" + self.name + " ,uvm_reg_cbs)\n"
        reg_text    += reg_rand_text + "\n"
        reg_text    += reg_build_text + "\n"
        reg_text    += reg_new_text + "\n"
        if reg.cov_type == 'cov_type':
            reg_text    += reg_coverage_text + "\n"
            reg_text    += reg_sample_text + "\n"
	
        reg_text    += 'endclass : ' + self.name + "\n\n"

        return reg_text

    def coverage_text(self):
        #if int(self.width) <33:
        coverage_text   = "\tcovergroup cg_bits();\n"
        coverage_text  += "\t\toption.per_instance = 1;\n"
        coverage_text  += "\t\toption.name = get_name();\n"
        #else:
        #    coverage_text   = "\tcovergroup cg_bits();\n"
        #    coverage_text  += "\t\toptions.auto_bin_max = 3;\n"
        #    coverage_text  += "\t\toption.name = get_name();\n"

        for field in self.field_list:
            #reg = reg_type.name[0:-5]
            #index = int(reg_type.width)/32
            #reg_base_addr = hex(int(reg_type.address[2:],16))
            #coverage_text  += "\t\t" + reg + ":coverpoint reg_offset{\n"
            coverage_text  += field.coverage_text()
            #for i in range(int(index)):
                #address = hex(4 * i) + hex(ord(reg_type.address[2:]))
                #print(reg_type.address[2:])
                #print(reg_base_addr[2:])
                #print(reg_type.address[2:].encode().hex())
                #address = hex(4 * i) + reg_type.address[2:].encode().hex()
                #address = sum([hex(4 * i),int(reg_type.address[2:],16)])
                #print(address)
                #address = 4 * i + int(reg_base_addr[2:],16)
                #print(address)
                #coverage_text  += "\t\t\tbins accessed_" + str(i) + "= {`UVM_REG_ADDR_WIDTH'h" + str(reg_type.address[2:]) + " + `UVM_REG_ADDR_WIDTH'h" + str(hex(4 * i))[2:] + "};\n"
            #coverage_text  += "\t\t\toption.weight = " + str(index)[:-2] + ";\n"
            #coverage_text  += "\t\t}\n\n"
        coverage_text  += "\tendgroup\n"
        return coverage_text

    def sample_text(self):
        sample_text   = "\tvirtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);\n"
        sample_text  += "\t\tif(get_coverage(UVM_CVR_REG_BITS)) begin\n"
        sample_text  += "\t\t\tm_data = data;\n"
        sample_text  += "\t\t\tm_be = byte_en;\n"
        sample_text  += "\t\t\tm_is_read = is_read;\n"		
        sample_text  += "\t\t\tcg_bits.sample();\n"
        sample_text  += "\t\tend\n"
        sample_text  += "\tendfunction\n"
        return sample_text		


class Block(object):
    def __init__(self):
        self.row        = None
        self.name       = None
        self.dig_name   = None
        self.address    = None
        self.hdlpath    = None
        self.cov_type   = None
        self.rst_fd_num = 0
        self.reg_list   = []
        self.block_list = []

    def new_text(self):
        new_text     = "\tfunction new(string name=\"" + self.name + "\");\n"
        new_text    += "\t\tsuper.new(name, UVM_CVR_ADDR_MAP);\n"
        if block.cov_type == 'addr':
            new_text    += "\t\tadd_coverage(UVM_CVR_ADDR_MAP);\n"
            new_text    += "\t\tif(has_coverage(UVM_CVR_ADDR_MAP)) begin\n"
            new_text    += "\t\t\tcg_addr = new(\"cg_addr\");\n"
            new_text    += "\t\tend\n"
        if self.name[0:3] != "mx2":
            for reg in self.reg_list:
                self.rst_fd_num += reg.rst_fd_num
            
        new_text    += "\t\t" + "rst_fd_num = 'd" + str(self.rst_fd_num) + ";\n"
        new_text    += "\tendfunction : new\n"

        return new_text


    def rand_text(self):
        rand_text  = "\n"
        rand_text += "\tlocal uvm_reg_data_t reg_offset;\n"
        rand_text += "\tlocal int rst_fd_num;\n"
        for reg in self.reg_list:
            rand_text += "\trand " + reg.name + " " + reg.name[0:-5] + ";\n"
        rand_text += "\n"

        return rand_text

    def build_text(self):
        build_text = "\tvirtual function void build();\n"
        for reg_type in self.reg_list:
            reg = reg_type.name[0:-5]
            build_text  += "\t\t" + reg + " = " +reg_type.name + "::type_id::create(\"" + reg + "\", , get_full_name());\n"
            build_text  += "\t\t" + reg + ".configure(this, null, \"\");\n"
            build_text  += "\t\t" + reg + ".build();\n"
        build_text  += "\t\t//add hdl path\n"

        for reg_type in self.reg_list:
            reg = reg_type.name[0:-5]
            for field in reg_type.field_list:
                if  field.regslicename != "":
                    build_text  += "\t\t" + reg + ".add_hdl_path_slice(\"" + field.regslicename + "\"," + str(field.bit_start) + ","+ str(field.bitwidth) + ");\n"
           # if reg_type.hdlpath != "":
            #    build_text  +=  "\t\t" + "add_hdl_path(\"" + reg_type.hdlpath + "\");\n"       

        build_text  += "\t\t//define address mappings\n"
        build_text  += "\t\tdefault_map = create_map(\"default_map\", 0, 4, UVM_LITTLE_ENDIAN);\n"
        for reg_type in self.reg_list:
            reg = reg_type.name[0:-5]
            build_text  += "\t\tdefault_map.add_reg(" + reg + ", `UVM_REG_ADDR_WIDTH'h" + reg_type.address[2:] + ", \"" + reg_type.virtual_type + "\");\n"

        for reg_type in self.reg_list:
            #reg = reg_type.name[0:-5]
            #for field in reg_type.field_list:
             #   if  field.regslicename != "":
              #      build_text  += "\t\t" + reg + ".add_hdl_path_slice(\"" + field.regslicename + "\"," + str(field.bit_start) + ","+ str(field.bitwidth) + ");\n"
            if reg_type.hdlpath != "":
                build_text  +=  "\t\t" + "this.add_hdl_path(\"" + str(reg_type.hdlpath) + "\");\n" 
        build_text  += "\tendfunction\n"

        return build_text

    def coverage_text(self):
        coverage_text   = "\tcovergroup cg_addr(input string name);\n"
        coverage_text  += "\t\toption.per_instance = 1;\n"
        coverage_text  += "\t\toption.name = get_name();\n"
        for reg_type in self.reg_list:
            reg = reg_type.name[0:-5]
            coverage_text  += "\t\t" + reg + ":coverpoint reg_offset{\n"
            coverage_text  += "\t\t\tbins accessed = {`UVM_REG_ADDR_WIDTH'h" + reg_type.address[2:] + "};\n"
            coverage_text  += "\t\t\toption.weight = 1;\n"
            coverage_text  += "\t\t}\n\n"
        coverage_text  += "\tendgroup\n"
        return coverage_text

    def sample_text(self):
        sample_text   = "\tfunction void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);\n"
        sample_text  += "\t\tif(get_coverage(UVM_CVR_ADDR_MAP)) begin\n"
        sample_text  += "\t\t\treg_offset = offset;\n"
        sample_text  += "\t\t\tcg_addr.sample();\n"
        sample_text  += "\t\tend\n"
        sample_text  += "\tendfunction\n"
        return sample_text		

    def block_text(self):
        block_rand_text = self.rand_text()
        block_build_text = self.build_text()
        block_new_text = self.new_text()
        block_coverage_text = self.coverage_text()
        block_sample_text   = self.sample_text()

        block_text       = 'class ' + self.name + " extends uvm_base_block;\n"
        block_text      += "\t`uvm_object_utils(" + self.name + ")\n"
        block_text      += block_rand_text + "\n"
        block_text      += block_build_text + "\n"
        if block.cov_type == 'addr':
            block_text      += block_coverage_text + "\n"	
        block_text      += block_new_text + "\n"
        if block.cov_type == 'addr':
            block_text      += block_sample_text + "\n"
        block_text      += 'endclass : ' + self.name + "\n\n"

        return block_text

    def block_main_text(self):
        block_main_text = "\nclass ral_gen_main extends uvm_base_block;\n"
        for block in self.block_list:
            self.rst_fd_num += block.rst_fd_num
            block_main_text     += "\trand " + block.name + " " + block.name[:-5] + ";\n"
            for reg in block.reg_list:
              block_main_text     += "\t" + reg.name + " " + reg.name[:-5] + ";\n"

        block_main_text     += "\n\tvirtual function void build();\n"
        block_main_text     += "\t\tdefault_map = create_map(\"default_map\", 0, 4, UVM_LITTLE_ENDIAN);\n"
        for block in self.block_list:
            block_main_text     += "\t\t" + block.name[:-5] + " = " + block.name + "::type_id::create(\"" + block.name[:-5] + "\", , get_full_name());\n"
            if block.hdlpath != "":
                block_main_text     += "\t\t" + block.name[:-5] + ".configure(this, \"" + block.hdlpath + "\");\n"
            else:
                block_main_text     += "\t\t" + block.name[:-5] + ".configure(this, \"\");\n"
            block_main_text     += "\t\t" + block.name[:-5] + ".build();\n"

            for reg in block.reg_list:
                block_main_text     += "\t\tthis." + reg.name[:-5] + " = this." + block.name[:-5] + "." + reg.name[:-5] + ";\n"

            block_main_text     += "\t\t" + block.name[:-5] + ".lock_model();\n"
            block_main_text     += "\t\t" + "default_map.add_submap(" + block.name[:-5] + ".default_map, `UVM_REG_ADDR_WIDTH'h" + block.address[2:] + ");\n"
        block_main_text     += "\n\tendfunction;\n"
        block_main_text     += "\n\t`uvm_object_utils(ral_gen_main)\n"
        block_main_text     += "\n\tfunction new(string name=\"ral_gen_main\");\n"
        block_main_text     += "\t\tsuper.new(name, UVM_NO_COVERAGE);\n"
        block_main_text     += "\tendfunction;\n"
        block_main_text     += "\nendclass : ral_gen_main"

        return block_main_text


def get_block(args_t,col_names, records):
    cov_type = args_t.input_coverage_type
    block_main = Block()
    #block = Block()
    title = Col_title_template()
    for row_num, record in enumerate(records):
        tag = record[col_names.index(title.label)]
        reg_match=re.match(reg_pattern,str(tag))
        #print("tag:::==== ",tag)
        if tag == "Block":
            block = Block()
            block.row		= row_num
            block.dig_name	= record[col_names.index(title.block_name)]
            block.endaddr     = record[col_names.index(title.end_addr)] 
            block.name		= record[col_names.index(title.block_name)][4:].lower() + "_type"
            block.address	= record[col_names.index(title.address)]
            block.hdlpath   = record[col_names.index(title.hdlpath)]
            # mx2_type, mx2_tiny_core_type is excluded  LipingTang @20221129 
            if block.name[0:3] == 'mx2' :
                block.cov_type  = False
            else:
                block.cov_type  = cov_type
            #block.cov_type  = cov_type
            block_main.block_list.append(block)

        #if tag == 'REG_8' or tag == 'REG_16' or tag == 'REG_32' or tag == 'REG_736' or tag == 'REG_128' or tag == 'REG_768' or tag == 'REG_608' or tag == 'REG_256' or tag == 'REG_4768':
        if reg_match:
            reg             = Register()
            reg.row         = row_num
            reg.block       = block.name
            reg.name        = record[col_names.index(title.reg_name)].lower() + "_type"
            reg.reg_endaddr = record[col_names.index(title.end_addr)]
            reg.width       = tag[4:]
            reg.address     = record[col_names.index(title.offset_addr)].lower()
            reg.hdlpath     = record[col_names.index(title.hdlpath)]
            reg.virtual_type = record[col_names.index(title.virtual_type)]
            if reg.block == 'mx2_type' or reg.block == 'mx2_tiny_type':
               reg.virtual_type = 'RW'
            else:
               reg.cov_type     = 'cov_type'
               if reg.virtual_type == "":
                  reg.virtual_type = 'RW'
               else:
                  reg.virtual_type = reg.virtual_type.upper()
               
            #if reg.virtual_type == "":
            #    reg.virtual_type = 'RW'
            #else:
             #   reg.virtual_type = reg.virtual_type.upper()

            if record[col_names.index(title.reset_value)] == "":
                reg.reset_value = reg.width + "'h0"
            else:
                reg.reset_value = record[col_names.index(title.reset_value)].lower()
            block_main.block_list[-1].reg_list.append(reg)
            #reg_list.append(reg)

        if tag == 'REG_BIT':
            field = Field()
            field.row           = row_num
            field.name          = record[col_names.index(title.field_name)].lower()
            field.reg           = reg.name
            field.bit_start     = eval(record[col_names.index(title.bit_start)])
            field.bit_end       = record[col_names.index(title.bit_end)]
            field.reset_value   = record[col_names.index(title.reset_value)]
            field.regslicename	= record[col_names.index(title.regslicename)]
            field.has_reset      = eval(record[col_names.index(title.has_reset)])
            if field.has_reset == "":
                field.has_reset = 0
            field.reset_source0     = record[col_names.index(title.reset_source0)]
            if field.reset_source0 == "":
                field.reset_source0 = '' 
            field.reset_source1     = record[col_names.index(title.reset_source1)]
            if field.reset_source1 == "":
                field.reset_source1 = ''

            if field.bit_end == "":
                field.bit_end = field.bit_start
            else:
                field.bit_end = eval(field.bit_end)
            field.bitwidth          = field.bit_end - field.bit_start + 1
            field.virtual_type      = record[col_names.index(title.virtual_type)]
            if field.reset_value == "":
                field.reset_value = str(field.bitwidth) + "'h0"
            else:
                #field.reset_value = field.reset_value
                field.reset_value = str(field.bitwidth) + "'h" + record[col_names.index(title.reset_value)][2:]

            if field.virtual_type == "" or field.virtual_type == 'NA':
                field.virtual_type = 'RW'

            field.virtual_type      = field.virtual_type.upper()
            if field.name == "rfu":
                field.name = field.name + str(field.bit_start)
                field.virtual_type = 'RO'
            block_main.block_list[-1].reg_list[-1].field_list.append(field)
            #reg_list[-1].field_list.append(field)

            #block.reg_list  = get_registers(block.name, col_names, records)
            #block_main.block_list.append(block)

    return block_main


if __name__ == '__main__':
    args_t = getparse()
    block_main  = Block()
    block	    = Block()
    records=[]

    with open(args_t.input_reg_table, mode='r', encoding='utf-8') as file:
        csv_reader = csv.reader(file)
        for row in csv_reader:
            records.append(row)

    block_main               = get_block(args_t,records[0], records[1:])    

    file_name       = args_t.output_regmdl_file
    ral_sv          = open(file_name, 'w')
  #  block_main_text = block_main.block_main_text()
    ral_head_t           = "//This file is automatically generated by gen_reg_model.py, please do not edit or commit!\n"
    ral_head_t          += "package RAL_PKG;\n\nimport uvm_pkg::*;\n`include \"uvm_macros.svh\"\n\n"
    ral_head_t  		   += "import reg_mdl_pkg::*;\n\n"
    ral_head_t          += "`define UVM_REG_ADDR_WIDTH 32 \n\n"
    
							
                 
    ral_t      = "\n"
    for block in block_main.block_list:
        for reg in block.reg_list:
            reg_text    = reg.reg_text()
            ral_t      += reg_text
        block_text = block.block_text()
        ral_t     += block_text
    block_main_text = block_main.block_main_text()
    ral_head_t          += "//Except mx2&mx2_tiny block, total fields num which has_reset = 1\n"
    ral_head_t          += "`define RST_FD_NUM  "+ str(block_main.rst_fd_num) + "\n"
    ral_sv.write(ral_head_t)

    ral_t      += block_main_text
    ral_t      += "\n\nendpackage: RAL_PKG"
    ral_sv.write(ral_t)
    ral_sv.close()

    # derived UVM_REG_DATA_WIDTH / UVM_HDL_MAX_WIDTH source for testjson2lst.py
    width_file = os.path.join(os.path.dirname(os.path.abspath(file_name)), "ral_reg_width")
    with open(width_file, 'w') as wf:
        wf.write(str(derive_reg_width(records)) + "\n")
    print("wrote %s" % width_file)

    vaid_col=[0,2,4,5,6,7,8,9,13,19]


    #ral_sv_t    = open(args_t.input_reg_table.replace("csv","md"), 'w')
    # md table view goes next to the generated model (verify/ral/), never into the
    # register-table directory - the CSV may live anywhere (WSIM_REG_TABLE)
    output_md_name=os.path.join(os.path.dirname(os.path.abspath(file_name)),
                                os.path.splitext(os.path.basename(args_t.input_reg_table))[0]+".md")
    ral_sv_t    = open(output_md_name, 'w')
    ral_md = "# Register Table  \n"
    ral_md += "| "
    for i in vaid_col:
        if records[0][i] == "":
            ral_md += " | "
        else:
            ral_md += str(records[0][i])+ " | "
    ral_md += "\n"

    for i in vaid_col:
        ral_md += "| --- "
    ral_md+="|\n"

    for row_num, record in enumerate(records[1:]):

        ral_md += "| "
        for i in vaid_col:
            if record[i] == "":
                ral_md += " | "
            else:
                ral_md += str(record[i]).replace("\n", "<br>") + " | "
        ral_md += "\n"
 
    ral_sv_t.write(ral_md)
    ral_sv_t.close()








