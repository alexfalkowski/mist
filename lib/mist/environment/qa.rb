module Mist::Environment::QA
  def environments
    [
        {
            name: 'PINCHme-US-QA-A',
            uri: 'http://pinchme-us-qa-a-jn9wvp4tew.elasticbeanstalk.com'
        },
        {
            name: 'PINCHme-US-QA-B',
            uri: 'http://pinchme-us-qa-b-ghruzpydi6.elasticbeanstalk.com'
        },
    ]
  end

  def domain
    'qa.pinchme.com.'
  end

  def application_name
    'PINCHme-US-QA'
  end
end
