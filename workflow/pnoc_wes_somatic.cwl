class: Workflow
cwlVersion: v1.0
id: kfdrc-pnoc-wes-somatic-workflow
requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  output_basename: string
  reference: { type: File, secondaryFiles: [.fai, ^.dict] }
  tumor_cram: { type: File, secondaryFiles: [.crai] }
  normal_cram: { type: File, secondaryFiles: [.crai] }
  normal_id: string
  tumor_id: string
  ref_tar_gz: { type: File, label: tar gzipped snpEff reference }
  exome_target_bed: { type: File, secondaryFiles: [.tbi], label: bed file of exome target regions }
  vep_cache: { type: File, label: tar gzipped cache from ensembl/local converted cache }
outputs:
  merged_strelka_vcf: { type: File, outputSource: merge_vcf/output }
  snpeff_annotated_vcf: { type: File, outputSource: snpeff_annotate/output }
  vep_annotated_vcf: { type: File, outputSource: vep_maf_annotate/output_vcf }
  vep_annotated_maf: { type: File, outputSource: vep_maf_annotate/output_maf }
  vep_warnings: { type: ["null", File] , outputSource: vep_maf_annotate/warn_txt }
steps:
  strelka2-wes:
    in:
      input_tumor_cram: tumor_cram
      input_normal_cram: normal_cram
      reference: reference
      exome_target_bed: exome_target_bed
    out: [output]
    run: ../tools/strelka2_wes.cwl
  merge_vcf:
    in:
      input_vcf: [ strelka2-wes/output_snv, strelka2-wes/output_indel ]
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