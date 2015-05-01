#! /bin/bash
#
# Licensed to Big Data Genomics (BDG) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The BDG licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

export ADAM_DRIVER_MEMORY="55g"
export ADAM_EXECUTOR_MEMORY="55g"
export SPARK_HOME="/home/ubuntu/spark-1.2.1-bin-hadoop2.4"
export ADAM_HOME="/home/ubuntu/adam"
export RNADAM_HOME="/home/ubuntu/RNAdam"

cd /mnt2/

# get two bit util
wget ftp://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit

# get c. elegans reference genome
wget ftp://ftp.ensembl.org/pub/release-79/fasta/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz
gunzip Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz

# make two bit file
./faToTwoBit Caenorhabditis_elegans.WBcel235.dna.toplevel.fa Caenorhabditis_elegans.WBcel235.dna.toplevel.2bit

# get c. elegans gtf
wget ftp://ftp.ensembl.org/pub/release-79/gtf/caenorhabditis_elegans/Caenorhabditis_elegans.WBcel235.79.gtf.gz
gunzip Caenorhabditis_elegans.WBcel235.79.gtf.gz

cd ~

# convert known snps file to adam variants file
${RNADAM_HOME}/bin/RNAdam-submit index \
    /mnt2/Caenorhabditis_elegans.WBcel235.dna.toplevel.2bit \
    /mnt2/Caenorhabditis_elegans.WBcel235.79.gtf \
    20 \
    /mnt2/Caenorhabditis_elegans.WBcel235.79.index \
    -print_metrics
