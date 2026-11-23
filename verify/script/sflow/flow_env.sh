# flow_env.sh - project-level settings shared by the simulation flows.
#
# Sourced (not executed) by sim/wsim and sim/wsim_oeda straight from
# verify/script/sflow/ - there is no deployed copy, so this file is the single
# definition point. Values are assigned directly on purpose: the repo is the
# source of truth, and a stale export in someone's shell must not silently
# switch the flow to another input. Change a value here, commit it, and every
# clone picks it up.
#
# Callers set $database_path (the repo root) before sourcing.
#
# Rule (CLAUDE.md): only PROJECT-level values belong here - one value shared by
# everyone running this project. MACHINE-level values (UVM_HOME, the OSS CAD
# Suite environment, VERDI_HOME, ...) differ per install and stay environment
# variables with in-script defaults; never pin them here.

# Register-table CSV consumed by RalGen. Only read when the selected filelist
# compiles the RAL model (i.e. enable_ral is on somewhere); its location is
# confirmed with the user through the spec2json intake gate before RAL is used.
WSIM_REG_TABLE="$database_path/hdl/common/reg_table/reg_table_reg_list.csv"

# ------------------------------------------------------------------------------
# Site settings (VCS server) - REVIEW ALL OF THESE AT THE LINUX MIGRATION.
# Values are identical to the former hard-coded literals (pure refactor).
# wsim forwards the ones the Makefile needs on the make command line.
# ------------------------------------------------------------------------------
# Python 3 for the flow helper scripts (RalGen, testjson2lst, Makefile seed).
WSIM_PYTHON="/opt/anaconda3/bin/python"
# Default LSF queue; also the pattern used to discover sibling queues.
WSIM_LSF_QUEUE="amd7t83"
# LSF cluster host configuration read for queue/host discovery.
WSIM_LSF_HOSTS_FILE="/lsf/conf/lsbatch/kulh1-clu-lsf01/configdir/lsb.hosts"
# LSF dispatch master switch: anything but TRUE runs every case locally.
WSIM_LSF_ENABLE="TRUE"
# Host-name fragments (3rd '-'-separated field of $HOST) allowed to submit to
# LSF; runs started on other hosts fall back to local execution. Empty = any host.
WSIM_LSF_SUBMIT_HOSTS="cch gat0"
# Execution-host names in WSIM_LSF_HOSTS_FILE, used for per-queue slot discovery.
WSIM_LSF_EXEC_HOST_REGEX="kulh1-a[0-9a-zA-Z]+-cch[0-9]+"
# sed expression mapping a host-group name in WSIM_LSF_HOSTS_FILE to its queue name.
WSIM_LSF_QUEUE_SED='s/amd/a/g'
# DPO learn/apply/reference database root.
WSIM_DPO_DB="/archive/project/SG/dpo_database"
