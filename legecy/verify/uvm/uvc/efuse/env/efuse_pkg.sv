`ifndef __EFUSE_PKG__SV__
`define __EFUSE_PKG__SV__

package efuse_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
import reg_addr::*;
  import base_uvc_pkg::*;

  `include "efuse_base_config.sv"
  `include "efuse_config.sv"

  `include "efuse_item.sv"
  `include "efuse_sequence_item.sv"
  `include "efuse_coverage_item.sv"
  `include "efuse_sequencer.sv"
  `include "efuse_driver.sv"
  `include "efuse_monitor.sv"
  `include "efuse_coverage.sv"
  `include "efuse_scoreboard.sv"
  `include "efuse_agent.sv"
  `include "efuse_env.sv"

  `ifdef MDL_EFUSE

    `include "efuse_reg2apb_adapter.sv"
    `include "efuse_block_test.sv"
    `include "efuse_block_seq.sv"
  `endif

endpackage: efuse_pkg

`endif //`ifndef __EFUSE_PKG__SV__
