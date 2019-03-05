class: Workflow
cwlVersion: v1.0
id: cbttc-pipe-workflow
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  output_basename: string
  reference: { type: File, secondaryFiles: [.fai, ^.dict] }
  threads: int
  tumor_cram: { type: File, secondaryFiles: [.crai] }
  normal_cram: { type: File, secondaryFiles: [.crai] }
  normal_id: string
  tumor_id: string
  chr_len: File
  ref_chrs: File
  ref_tar_gz: { type: File, label: tar gzipped snpEff reference }
  hg38_strelka_bed: { type: File, secondaryFiles: [.tbi], label: bed file of hg38 chrs without contigs }
  vep_cache: { type: File, label: tar gzipped cache from ensembl/local converted cache }

outputs:
  merged_strelka_vcf: { type: File, outputSource: merge_vcf/output }
  manta_sv: {type: File, outputSource: manta/output_sv}
  snpeff_annotated_vcf: { type: File, outputSource: snpeff_annotate/output }
  vep_annotated_vcf: { type: File, outputSource: vep_maf_annotate/output_vcf }
  vep_annotated_maf: { type: File, outputSource: vep_maf_annotate/output_maf }
  vep_warnings: { type: ["null", File] , outputSource: vep_maf_annotate/warn_txt }
  cnv_result: { type: File, outputSource: control_free_c/output_cnv }
  cnv_bam_ratio: { type: File, outputSource: control_free_c/output_txt }
  cnv_pval: { type: File, outputSource: control_free_c_r/output_pval }
  cnv_png: { type: File, outputSource: control_free_c_viz/output_png }

steps:
  samtools_tumor_cram2bam:
    in:
      reference: reference
      threads: threads
      input_reads: tumor_cram
    out: [output]
    run: ../tools/samtools_cram2bam.cwl

  samtools_normal_cram2bam:
    in:
      reference: reference
      threads: threads
      input_reads: normal_cram
    out: [output]
    run: ../tools/samtools_cram2bam.cwl

  control_free_c:
    in:
      ref_chrs: ref_chrs
      chr_len: chr_len
      tumor_bam: samtools_tumor_cram2bam/bam_file
      normal_bam: samtools_normal_cram2bam/bam_file
      output_basename: output_basename
    out: [output]
    run: ../tools/control_freec.cwl

  control_free_c_r:
    in:
      cnv_bam_ratio: control_free_c/output_txt
      cnv_result: control_free_c/output_cnv
    out: [output]
    run: ../tools/control_freec_R.cwl

  control_free_c_viz:
    in:
      output_basename: output_basename
      cnv_bam_ratio: control_free_c/output_txt
    out: [output]
    run: ../tools/control_freec_visualize.cwl

  strelka2:
    in:
      input_tumor_cram: tumor_cram
      input_normal_cram: normal_cram
      reference: reference
      hg38_strelka_bed: hg38_strelka_bed
    out: [output]
    run: ../tools/strelka2.cwl

  manta:
    in:
      input_tumor_cram: tumor_cram
      input_normal_cram: normal_cram
      reference: reference
      ref_bed: hg38_strelka_bed
      output_basename: output_basename
    out: [output_sv]
    run: ../tools/manta.cwl

  merge_vcf:
    in:
      input_vcf: [ strelka2/output_snv, strelka2/output_indel ]
      output_vcf_basename: output_basename
      normal_id: normal_id
      tumor_id: tumor_id
    out: [output]
    run: ../tools/picard_mergevcfs_python_renamesample.cwl

  filter_vcf:
    in:
      input_vcf: merge_vcf/output
      output_basename: output_basename
    out: [output]
    run: ../tools/filter_vcf.cwl

  snpeff_annotate:
    in:
      input_vcf: filter_vcf/output
      ref_tar_gz: ref_tar_gz
      output_basename: output_basename
    out: [output]
    run: ../tools/snpEff_annotate.cwl

  vep_maf_annotate:
    in:
      reference: reference
      input_vcf: filter_vcf/output
      output_basename: output_basename
      tumor_id: tumor_id
      normal_id: normal_id
      cache: vep_cache
    out: [output]
    run: ../tools/vep_plus_maf.cwl

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2