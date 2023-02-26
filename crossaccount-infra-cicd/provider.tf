provider "aws" {
  region  = "ca-central-1"
  profile = "source-account-profile"
}

provider "aws" {
  alias   = "target"
  region  = "ca-central-1"
  profile = "target-account-profile"
}
