cwlVersion: v1.0
class: CommandLineTool
id: filter-vcf-pass
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 2000
  - class: DockerRequirement
    dockerPull: 'migbro/samtools:ubuntu'
baseCommand: [zcat]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      $(inputs.input_vcf.path)
      | grep -E '^#|PASS'
      | bgzip -c > $(inputs.output_basename).strelka.PASS.vcf.gz
      && tabix $(inputs.output_basename).strelka.PASS.vcf.gz
inputs:
  input_vcf: { type: File,  secondaryFiles: [.tbi] }
  output_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.PASS.vcf.gz'
    secondaryFiles: [.tbi]