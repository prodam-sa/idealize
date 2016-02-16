module Procon
  VERSION   = '0.1.0'
  RELEASE   = ''
  TIMESTAMP = '2016-01-13 09:19:08 -0400'

  def self.info
    "#{name} v#{VERSION} (#{RELEASE})"
  end

  def self.to_h
    { :name      => name,
      :version   => VERSION,
      :semver    => VERSION.to_semver_h,
      :release   => RELEASE,
      :timestamp => TIMESTAMP }
  end
end
