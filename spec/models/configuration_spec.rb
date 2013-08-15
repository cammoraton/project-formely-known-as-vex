require 'spec_helper'

describe Configuration do
  let(:testobject) { Configuration }
  it { testobject.new.should validate_presence_of(:name) }
  # Shoulda-matchers won't do this with mongo as it'll complain about columns_hash
  # it { testobject.new.should validate_uniqueness_of(:name).scoped_to(:_type) }
  
end