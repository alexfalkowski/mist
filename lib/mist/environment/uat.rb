module Mist::Environment::UAT
  def environments
    [
        {
            name: 'PINCHme-US-UAT-A',
            uri: 'https://pinchme-us-uat-a-nkgydjxzg5.elasticbeanstalk.com'
        },
        {
            name: 'PINCHme-US-UAT-B',
            uri: 'https://pinchme-us-uat-b-gqf87sffny.elasticbeanstalk.com'
        },
    ]
  end

  def domain
    'uat.pinchme.com.'
  end

  def endpoint
    'https://uat.pinchme.com'
  end

  def application_name
    'PINCHme-US-UAT'
  end
end
