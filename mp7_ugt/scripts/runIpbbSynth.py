#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import toolbox as tb
import mp7patch

import argparse
import urllib
import shutil
import logging
from distutils.dir_util import copy_tree
import subprocess
import ConfigParser
import sys, os, re
import socket

HB_PC = 'powerslave'
"""if HB_PC => Bergauer PC 'powerslave' Xilinx Vivado installation location = '/opt/Xilinx/Vivado."""
"""else => Default Xilinx Vivado installation location = '/opt/xilinx/Vivado'."""
if socket.gethostname() == HB_PC:
    VIVADO_BASE_DIR = '/opt/Xilinx/Vivado'
else:
    VIVADO_BASE_DIR = '/opt/xilinx/Vivado'

EXIT_SUCCESS = 0
EXIT_FAILURE = 1

# Set correct FW_TYPE and BOARD_TYPE for each project!
FW_TYPE = 'ugt'
BOARD_TYPE = 'mp7'

BoardAliases = {
    'mp7_690es': 'r1',
    'mp7xe_690': 'xe',
}

DefaultBoardType = 'mp7xe_690'
"""Default board type to be used."""

DefaultFirmwareDir = os.path.expanduser("~/work_ipbb/mp7_ugt")
"""Default output directory for firmware builds."""

def run_command(*args):
    command = ' '.join(args)
    logging.info(">$ %s", command)
    os.system(command)

def vivado_t(version):
    """Validates Xilinx Vivado version number."""
    if not re.match(r'^\d{4}\.\d+$', version):
        raise ValueError("not a xilinx vivado version: '{version}'".format(**locals()))
    return version

def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument('vivado', type=vivado_t, help="xilinx vivado version to run, eg. '2018.2'")
    parser.add_argument('-t', '--tag', metavar='<tag>', required=True, help="mp7fw tag")
    parser.add_argument('--board', metavar='<type>', default=DefaultBoardType, choices=BoardAliases.keys(), help="set board type (default is {})".format(DefaultBoardType))
    parser.add_argument('-p', '--path', metavar='<path>', default=DefaultFirmwareDir, type=os.path.abspath, help="fw build path")
    parser.add_argument('-m', '--menu', metavar='<menu>', required=True, type=os.path.abspath, help="path to L1Menu_ directory")
    parser.add_argument('-b', '--build', metavar='<version>', required=True, type=tb.build_t, help='menu build version (eg. 0x1001)')
    parser.add_argument('--ugt', metavar='<version>', required=True, help='ugt master, branch name or tag name')
    return parser.parse_args()

def main():
    """Main routine."""

    # Parse command line arguments.
    args = parse_args()

    # Setup console logging
    logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

    # Fetch menu name from path.
    menu_name = os.path.basename(args.menu)

    if not menu_name.startswith('L1Menu_'):
        raise RuntimeError("Invalid menu name: {}".format(menu_name))

    # Compile build root directory
    project_type = "{}_{}".format(BOARD_TYPE, FW_TYPE)
    build_name = "0x{}".format(args.build)
    ipbb_dir = os.path.join(args.path, project_type, args.tag, menu_name, build_name)
    #print "ipbb_dir:", ipbb_dir

    if os.path.isdir(ipbb_dir):
        raise RuntimeError("build area alredy exists: {}".format(ipbb_dir))

    # Fetch number of menu modules.
    modules = tb.count_modules(args.menu)
    #print "modules:", modules

    if not modules:
        raise RuntimeError("Menu contains no modules")

# Insert: Check, if kinit is set!
    
    for module_id in range(modules):
        module_name = 'module_{}'.format(module_id)
        cmd_source_ipbb = "source ipbb-0.2.8/env.sh"
        #print "cmd_source_ipbb:", cmd_source_ipbb
        ipbb_module_dir = os.path.join(ipbb_dir, module_name)
        #print "ipbb_module_dir:", ipbb_module_dir
        ipbb_src_fw_dir = os.path.abspath(os.path.join(ipbb_module_dir, 'src', 'ugt', 'mp7_ugt', 'firmware'))
        #print "ipbb_src_fw_dir:", ipbb_src_fw_dir
        cmd_ipbb_init = "ipbb init {ipbb_module_dir}".format(**locals())
        #print "cmd_ipbb_init:", cmd_ipbb_init
        cmd_ipbb_add_ipb = "ipbb add git https://github.com/ipbus/ipbus-firmware.git -b master"
        #print "cmd_ipbb_add_ipb:", cmd_ipbb_add_ipb
        cmd_ipbb_add_mp7 = "ipbb add git https://:@gitlab.cern.ch:8443/hbergaue/mp7.git -b {args.tag}_ugt".format(**locals())
        #print "cmd_ipbb_add_mp7:", cmd_ipbb_add_mp7
        cmd_ipbb_add_ugt = "ipbb add git https://:@gitlab.cern.ch:8443/hbergaue/ugt.git -b {args.ugt}".format(**locals())
        #print "cmd_ipbb_add_ugt:", cmd_ipbb_add_ugt
        logging.info("===========================================================================")
        logging.info("creating IPBB area for %s ...", module_name)
        command = 'bash -c "cd; {cmd_source_ipbb}; {cmd_ipbb_init}; cd {ipbb_module_dir}; {cmd_ipbb_add_ipb} && {cmd_ipbb_add_mp7} && {cmd_ipbb_add_ugt}"'.format(**locals())
        run_command(command)
        
        # Removing unused directories
        logging.info("removing src directories of unused amc502 fw ...")
        command = 'bash -c "cd; cd {ipbb_module_dir}/src/ugt; rm -rf amc502_extcond && rm -rf amc502_finor && rm -rf amc502_finor_pre && rm -rf mp7_tdf"'.format(**locals())
        run_command(command)

        # Read generated VHDL snippets
        vhdl_producer_dir = os.path.join(args.menu, 'vhdl', module_name, 'src')

        logging.info("replace VHDL templates with snippets from VHDL Producer ...")
        replace_map = {
            '{{algo_index}}': tb.read_file(os.path.join(vhdl_producer_dir, 'algo_index.vhd')),
            '{{ugt_constants}}': tb.read_file(os.path.join(vhdl_producer_dir, 'ugt_constants.vhd')),
            '{{gtl_module_signals}}': tb.read_file(os.path.join(vhdl_producer_dir, 'gtl_module_signals.vhd')),
            '{{gtl_module_instances}}': tb.read_file(os.path.join(vhdl_producer_dir, 'gtl_module_instances.vhd')),
        }

        gtl_fdl_wrapper_dir = os.path.join(ipbb_src_fw_dir, 'hdl', 'gt_mp7_core', 'gtl_fdl_wrapper')
        gtl_dir = os.path.join(gtl_fdl_wrapper_dir, 'gtl')
        fdl_dir = os.path.join(gtl_fdl_wrapper_dir, 'fdl')

        # Patch VHDL files in IPBB area (
        tb.template_replace(os.path.join(fdl_dir, 'algo_mapping_rop_tpl.vhd'), replace_map, os.path.join(fdl_dir, 'algo_mapping_rop.vhd'))
        tb.template_replace(os.path.join(gtl_dir, 'gtl_pkg_tpl.vhd'), replace_map, os.path.join(gtl_dir, 'gtl_pkg.vhd'))
        tb.template_replace(os.path.join(gtl_dir, 'gtl_module_tpl.vhd'), replace_map, os.path.join(gtl_dir, 'gtl_module.vhd'))

        logging.info("patch the target package with current UNIX timestamp/username/hostname ...")
        TARGET_PKG_TPL = os.path.join(ipbb_src_fw_dir, 'hdl', 'gt_mp7_top_pkg_tpl.vhd')
        TARGET_PKG = os.path.join(ipbb_src_fw_dir, 'hdl', 'gt_mp7_top_pkg.vhd')
        #print "TARGET_PKG:", TARGET_PKG        
        subprocess.check_call(['python', os.path.join(ipbb_src_fw_dir, '..', 'scripts', 'pkgpatch.py'), '--build', args.build, TARGET_PKG_TPL, TARGET_PKG])

        # Vivado settings
        settings64 = os.path.join(VIVADO_BASE_DIR, args.vivado, 'settings64.sh')
        if not os.path.isfile(settings64):
            raise RuntimeError(
                "no such Xilinx Vivado settings file '{settings64}'\n" \
                "  check if Xilinx Vivado {args.vivado} is installed on this machine.".format(**locals())
            )

        logging.info("creating IPBB project ...")
        cmd_ipbb_proj_create = "ipbb proj create vivado mp7_ugt_{build_name}_{module_id} mp7:../ugt/mp7_ugt".format(**locals())
        command = 'bash -c "cd; {cmd_source_ipbb}; cd {ipbb_module_dir}; {cmd_ipbb_proj_create}"'.format(**locals())
        run_command(command)
        
        logging.info("running IPBB project, synthesis and implementation, creating bitfile ...")
        cmd_ipbb_project = "ipbb vivado project"
        cmd_ipbb_synth = "ipbb vivado synth"
        cmd_ipbb_impl = "ipbb vivado impl"
        cmd_ipbb_bitfile = "ipbb vivado package"
        command = 'bash -c "cd; {cmd_source_ipbb}; source {settings64}; cd {ipbb_module_dir}/proj/mp7_ugt_{build_name}_{module_id}; {cmd_ipbb_project} && {cmd_ipbb_synth} && {cmd_ipbb_impl} && {cmd_ipbb_bitfile}"'.format(**locals())

        session = "build_{build_name}_{module_id}".format(**locals())
        logging.info("starting screen session '%s' for module %s ...", session, module_id)
        run_command('screen', '-dmS', session, command)

    # list running screen sessions
    run_command('screen', '-ls')

    logging.info("done.")

if __name__ == '__main__':
    try:
        main()
    except RuntimeError, message:
        logging.error(message)
        sys.exit(EXIT_FAILURE)
    sys.exit(EXIT_SUCCESS)