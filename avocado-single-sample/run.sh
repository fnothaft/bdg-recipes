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
export ADAM_OPTS="--conf spark.shuffle.service.enable=true"
export AVOCADO_DRIVER_MEMORY="50g"
export AVOCADO_EXECUTOR_MEMORY="50g"
export AVOCADO_OPTS="--conf spark.shuffle.service.enable=true --conf spark.shuffle.manager=sort --conf spark.shuffle.blockTransferService=netty --conf spark.shuffle.memoryFraction=0.3 --conf spark.storage.memoryFraction=0.1 --conf spark.io.compression.codec=org.bdgenomics.utils.serialization.compression.GzipCompressionCodec --conf spark.shuffle.manager=sort --conf spark.shuffle.blockTransferService=netty"

# start MR nodes
./ephemeral-hdfs/bin/stop-all.sh
sleep 10
./ephemeral-hdfs/bin/start-all.sh

# make a directory in hdfs
./ephemeral-hdfs/bin/hadoop fs -mkdir .

# pull NA12878 from 1000g
./ephemeral-hdfs/bin/hadoop distcp \
    s3n://bdg-eggo/1kg/na12878-high-coverage-wgs \
    ${hdfs_root}/user/${USER}/NA12878.adam

# pull reference down
cd /mnt
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
gunzip hs37d5.fa.gz
cd ~
./ephemeral-hdfs/bin/hadoop fs -put /mnt/hs37d5.fa .

# convert fasta to adam nucleotide file
${ADAM_HOME}/bin/adam-submit fasta2adam \
    ${hdfs_root}/user/${USER}/hs37d5.fa \
    ${hdfs_root}/user/${USER}/hs37d5.adam

# make config file
python ${BDG_RECIPES_HOME}/avocado-single-sample/make-config.py ${hdfs_root} > ${AVOCADO_HOME}/avocado.config

# run avocado
${AVOCADO_HOME}/bin/avocado-submit \
    ${hdfs_root}/user/${USER}/NA12878.adam \
    ${hdfs_root}/user/${USER}/hs37d5.adam \
    ${hdfs_root}/user/${USER}/NA12878.var.adam \
    ${AVOCADO_HOME}/avocado.config

# convert avocado variant calls to vcf
${ADAM_HOME}/bin/adam-submit \
    adam2vcf \
    ${hdfs_root}/user/NA12878.var.adam \
    ${hdfs_root}/user/NA12878.vcf \
    -sort_on_save
