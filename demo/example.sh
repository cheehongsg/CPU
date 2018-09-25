export RUN=${1}
export NTHREAD=${2}
export LOGFILE=${RUN}.cpu.log

# split tag in read
echo `date` STARTED ${RUN} cpu tags .. | tee -a ${LOGFILE}
./cpu tag -W -T 18 -t ${NTHREAD} -O ${RUN} ${RUN}.R1.fastq.gz ${RUN}.R2.fastq.gz 2>> ${LOGFILE}
echo `date` ENDED ${RUN} cpu tags .. | tee -a ${LOGFILE}

# compress splitted tags
echo `date` 'STARTED Compressing FL NC paired tags ..' | tee -a ${LOGFILE}
gzip -f ${RUN}.FullLinker.NonChimeric.paired.fastq 2>>${LOGFILE}
echo `date` 'ENDED Compressing FL NC paired tags ..' | tee -a ${LOGFILE}

# mapping
echo `date` STARTED Mapping FL NC paired tags .. | tee -a ${LOGFILE}
./cpu memaln -T 15 -t ${NTHREAD} mm10 ${RUN}.FullLinker.NonChimeric.paired.fastq.gz 2>> ${LOGFILE} 1>${RUN}.FullLinker.NonChimeric.paired.sam
echo `date` ENDED Mapping FL NC paired tags .. | tee -a ${LOGFILE}
echo `date` 'STARTED Compressing FL NC memaln sam file ..' | tee -a ${LOGFILE}
gzip ${RUN}.FullLinker.NonChimeric.paired.sam 2>&1  | tee -a ${LOGFILE}
echo `date` 'ENDED Compressing FL NC memaln sam file ..' | tee -a ${LOGFILE}

# pairing
echo `date` STARTED Pairing FL NC paired tags .. | tee -a ${LOGFILE}
./cpu pair -S -t ${NTHREAD} ${RUN}.FullLinker.NonChimeric.paired.sam.gz 1>${RUN}.FullLinker.NonChimeric.paired.stat.xls 2>> ${LOGFILE}
echo `date` ENDED Pairing FL NC paired tags .. | tee -a ${LOGFILE}

# deduplication
echo `date` STARATED De-duplicating FL NC paired tags UU .. | tee -a ${LOGFILE}
./cpu dedup -g -t ${NTHREAD} ${RUN}.FullLinker.NonChimeric.paired.UU.bam 1>${RUN}.FullLinker.NonChimeric.paired.UU.dedup.lc 2>> ${LOGFILE}
echo `date` ENDED De-duplicating FL NC paired tags UU .. | tee -a ${LOGFILE}
echo `date` removing transient file .. | tee -a ${LOGFILE}
rm ${RUN}.FullLinker.NonChimeric.paired.UU.dedup 2>> ${LOGFILE}

# cluster tags
echo `date` STARTED ${RUN} cpu clustering.. | tee -a ${LOGFILE}
./cpu cluster -g -M -B 1000 -5 5,-20 -3 5,980 -t 1 -O ${RUN}.e1K ${RUN}.FullLinker.NonChimeric.paired.UU.nr.bam 2>&1 | tee -a ${LOGFILE}
echo `date` ENDED ${RUN} cpu clustering.. | tee -a ${LOGFILE}
echo `date` removing transient file .. | tee -a ${LOGFILE}
rm ${RUN}.e1K.cpu.cluster 2>> ${LOGFILE}

# generate clustered tags for ChiaSig
echo `date` Decompressing cis interaction clusters for ChiaSig .. | tee -a ${LOGFILE}
gunzip ${RUN}.e1K.clusters.cis.chiasig.gz
echo `date` STARTED ChiaSig on cis interactions .. | tee -a ${LOGFILE}
./ChiaSig -c 2 -p -t ${NTHREAD} ${RUN}.e1K.clusters.cis.chiasig >${RUN}.e1K.clusters.cis.interaction 2>${RUN}.e1K.clusters.cis.interaction.err
echo `date` ENDED ChiaSig on cis interactions .. | tee -a ${LOGFILE}

