import 'https://gist.githubusercontent.com/seandavi/cb005cc2604262d7a7d7c5eaa988195e/raw/424a1888a51c42c93b519893efdc724a9bfebf74/salmon.wdl' as salmon_wdl

workflow salmon {
  File transcript_file
  Array[File] fastqs
  Int kmer = 31
  String transcript_index = "transcript_index"
  Int bootstraps = 25
  File ? gencode_gtf

  call salmon_wdl.salmon_index {
    input:
    transcript_file = transcript_file,
    transcript_index = transcript_index,
    gencode_gtf = gencode_gtf,
    kmer = kmer
  }
  call salmon_wdl.salmon_quant {
    input:
    fastqs = fastqs,
    gencode_gtf = gencode_gtf,
    transcript_index = transcript_index,
    index_tar_file = salmon_index.index_tar_file
  }
}
