module ApplicationHelper
  def tool_labels
    [%w[vicuna vicuna],
     %w[sam_tools sam_tools],
     %w[bwa bwa],
     %w[bwa2 bwa2],
     %w[bowtie bowtie],
     %w[bowtie2 bowtie2]]
  end

  def reference_genome_labels
    [%w[hg19 hg19],
     %w[Ribosomal_RNA Ribosomal_RNA]]
  end
end
