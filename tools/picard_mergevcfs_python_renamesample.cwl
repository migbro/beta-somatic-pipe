cwlVersion: v1.0
class: CommandLineTool
id: picard_mergevcfs_python_renamesample
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 3000
  - class: DockerRequirement
    dockerPull: 'migbro/picard:rename'
baseCommand: [ java, -Xms2000m, -jar, /picard.jar, MergeVcfs]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      OUTPUT=/dev/stdout
      CREATE_INDEX=false
  - position: 2 
    shellQuote: false
    valueFrom: >-
      | python /vcf_somatic_sample_rename.py $(inputs.normal_id) $(inputs.tumor_id)
      | bgzip -c  > $(inputs.output_vcf_basename).strelka.vcf.gz
      && tabix -p vcf $(inputs.output_vcf_basename).strelka.vcf.gz
inputs:
  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
    secondaryFiles:
      - .tbi
  output_vcf_basename:
    type: string
  normal_id:
    type: string
  tumor_id:
    type: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles:
      - .tbi