module Mist::Environment::UAT
  def environments
    [
        {
            name: 'PINCHme-US-UAT-A',
            uri: 'http://pinchme-us-uat-a-nkgydjxzg5.elasticbeanstalk.com'
        },
        {
            name: 'PINCHme-US-UAT-B',
            uri: 'http://pinchme-us-uat-b-gqf87sffny.elasticbeanstalk.com'
        },
    ]
  end

  def domain
    'uat.pinchme.com.'
  end

  def application_name
    'PINCHme-US-UAT'
  end
end
