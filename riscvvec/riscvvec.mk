#=========================================================================
# riscvvec Subpackage
#=========================================================================

riscvvec_deps = \
  vc \
  imuldiv \

riscvvec_srcs = \
  riscvvec-CoreDpath.v \
  riscvvec-CoreDpathRegfile.v \
  riscvvec-CoreDpathAlu.v \
  riscvvec-CoreCtrl.v \
  riscvvec-Core.v \
  riscvvec-InstMsg.v \
  riscvvec-CoreDpathPipeMulDiv.v \

riscvvec_test_srcs = \
  riscvvec-InstMsg.t.v \
  riscvvec-CoreDpathPipeMulDiv.t.v \

riscvvec_prog_srcs = \
  riscvvec-sim.v \
  riscvvec-randdelay-sim.v \

