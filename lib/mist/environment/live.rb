module Mist::Environment::LIVE
  def environments
    [
      {
        name: 'PINCHme-US-A',
        uri: 'https://pinchme-us-a-pcix3kmhzk.elasticbeanstalk.com'
      },
      {
        name: 'PINCHme-US-B',
        uri: 'https://pinchme-us-b-9tw6w5p6mt.elasticbeanstalk.com'
      },
    ]
  end

  # TODO: This needs to change to www.pinchme.com.
  def domain
    'live.pinchme.com.'
  end

  # TODO: This needs to change to https://www.pinchme.com
  def endpoint
    'https://live.pinchme.com'
  end

  def application_name
    'PINCHme-US'
  end
end
