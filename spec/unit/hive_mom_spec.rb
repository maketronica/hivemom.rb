describe HiveMom do
  describe '.config' do
    before do
      HiveMom.config.test = 'foo'
    end

    it 'returns previously set settings' do
      expect(HiveMom.config.test).to eq('foo')
    end
  end
end
