class AddReferenceGenomeToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :reference_genome, :string
  end
end
