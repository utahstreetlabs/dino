module Dino
  class ClientError < StandardError; end
  class BadRequest < ClientError; end
  class Forbidden < ClientError; end
  class NotFound < ClientError; end
  class Conflict < ClientError; end
  class UnprocessableEntity < ClientError; end
end
