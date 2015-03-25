import sys

config = '''
{
  AlignedReads = {
  }
  reassemblyExplorer = {
    mismatchRateThreshold = 0.03;
    targetRegionLength = 2000;
    targetFlankLength = 100;
  }
  biallelicGenotyper = {
    useEM = false;
    maxEMIterations = 10;
    emTolerance = 0.01;
  }
  nonRef = {
  }

  inputStage = AlignedReads;

  preprocessorNames = ( );
  preprocessorAlgorithms = ( );

  explorerName = reassemblyExplorer;
  explorerAlgorithm = ReassemblyExplorer;

  genotyperName = biallelicGenotyper;
  genotyperAlgorithm = BiallelicGenotyper;

  postprocessorNames = ( nonRef );
  postprocessorAlgorithms = ( filterReferenceCalls );
}
'''

print config 
