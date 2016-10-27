#
# A few helpers do deal with our fixtures
#

def fixture_file(name)
  File.read(File.join SPEC_PATH, 'fixtures', name)
end
