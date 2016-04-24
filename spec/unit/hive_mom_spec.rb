describe HiveMom do
  describe '.config' do
    before do
      HiveMom.config.test = 'foo'
    end

    it 'returns previously set settings' do
      expect(HiveMom.config.test).to eq('foo')
    end
  end

  describe '.s3_bucket' do
    let(:region) { 'someregion' }
    let(:resource) { double('resource') }

    before do
      HiveMom.config.aws_region = region
      allow(Aws::S3::Resource)
        .to receive(:new)
        .with(region: region)
        .and_return(resource)
    end

    it 'gets a bucket' do
      expect(resource).to receive(:bucket).with('hivemom-datafiles-test')
      HiveMom.s3_bucket
    end
  end
end
