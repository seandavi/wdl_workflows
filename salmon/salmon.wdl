# salmon wdl
#
# Assumes gencode here!!!!
#
#############################

task salmon_index {

  File transcript_file
  Int kmer 
  String transcript_index
  File gencode_gtf


  String dollar = "$"
  command <<<
    salmon index -t ${transcript_file} -k ${kmer} --type quasi -i ${transcript_index} --gencode
    tar -cvzf transcript_index.tar.gz ${transcript_index}
  >>>

  runtime {
    docker: "quay.io/seandavi/salmon:0.11.3"
    cpu: "1"
    memory: "8GB"
  }

  output {
    File index_tar_file = "transcript_index.tar.gz"
  }
}

task salmon_quant {
  File index_tar_file
  String transcript_index = "transcript_index"
  Array[File] fastqs

  # gencode_gtf MUST be unzipped and end in .gtf
  File gencode_gtf


  String dollar = "$"
  command <<<
    tar -xvzf ${index_tar_file}
    salmon quant --dumpEq \
    --threads 8 \
    --numBootstraps 25 \
    --gcBias \
    --seqBias \
    --index ${transcript_index} \
    --libType A \
    --output output \
    `make_salmon_read_string.py ${sep="," fastqs}` -g ${gencode_gtf}
    # gzip some of the big files
    gzip output/aux_info/ambig_info.tsv
    gzip output/aux_info/eq_classes.txt
    gzip output/libParams/flenDist.txt
    gzip output/quant.sf
    gzip output/quant.genes.sf
  >>>

  runtime {
    docker: "quay.io/seandavi/salmon:0.11.3"
    cpu: "8"
    memory: "16GB"
  }

  output {
    File ambig_info_tsv = "output/aux_info/ambig_info.tsv.gz"
    File bootstraps = "output/aux_info/bootstrap/bootstraps.gz"
    File names_tsv = "output/aux_info/bootstrap/names.tsv.gz"
    File eq_classes_txt = "output/aux_info/eq_classes.txt.gz"
    File exp3_seq = "output/aux_info/exp3_seq.gz"
    File exp5_seq = "output/aux_info/exp5_seq.gz"
    File exp_gc = "output/aux_info/exp_gc.gz"
    File expected_bias = "output/aux_info/expected_bias.gz"
    File fld = "output/aux_info/fld.gz"
    File meta_info_json = "output/aux_info/meta_info.json"
    File obs3_seq = "output/aux_info/obs3_seq.gz"
    File obs5_seq = "output/aux_info/obs5_seq.gz"
    File obs_gc = "output/aux_info/obs_gc.gz"
    File observed_bias = "output/aux_info/observed_bias.gz"
    File observed_bias_3p = "output/aux_info/observed_bias_3p.gz"
    File cmd_info_json = "output/cmd_info.json"
    File lib_format_counts_json = "output/lib_format_counts.json"
    File flenDist_txt = "output/libParams/flenDist.txt.gz"
    File salmon_quant_log = "output/logs/salmon_quant.log"
    File quant_sf = "output/quant.sf.gz"
    File quant_genes_sf = "output/quant.genes.sf.gz"
  }
}


