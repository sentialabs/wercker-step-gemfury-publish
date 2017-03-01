#!/bin/sh

main() {
  # Validate Input
  if [ -z "$WERCKER_GEMFURY_PUBLISH_ORG" ]; then
    fail "org: argument cannot be empty"
  fi

  if [ -z "$WERCKER_GEMFURY_PUBLISH_GEMSPEC" ]; then
    fail "gemspec: argument cannot be empty"
  fi

  if [ ! -f "$WERCKER_GEMFURY_PUBLISH_GEMSPEC" ]; then
    fail "gemspec: file not found '$WERCKER_GEMFURY_PUBLISH_GEMSPEC'"
  fi


  # Fallback to global FURY_AUTH variable
  if [ -z "$WERCKER_GEMFURY_PUBLISH_TOKEN" ]; then
    if [ -z "$FURY_AUTH" ]; then
      fail "token: argument emtpy and no global \$FURY_AUTH set"
    fi
    WERCKER_GEMFURY_PUBLISH_TOKEN=$FURY_AUTH
  fi


  # Discover gem name and version from the gemspec
  WERCKER_GEMFURY_PUBLISH_GEM_NAME=`ruby -r rubygems -e "puts Gem::Specification::load('$WERCKER_GIT_REPOSITORY.gemspec').name"`
  WERCKER_GEMFURY_PUBLISH_GEM_VERSION=`ruby -r rubygems -e "puts Gem::Specification::load('$WERCKER_GIT_REPOSITORY.gemspec').version"`
  WERCKER_GEMFURY_PUBLISH_GEM="$WERCKER_GEMFURY_PUBLISH_GEM_NAME-$WERCKER_GEMFURY_PUBLISH_GEM_VERSION.gem"

  if [ -z "$WERCKER_GEMFURY_PUBLISH_GEM_NAME" ]; then
    fail "could not determine name from the gemspec"
  fi

  if [ -z "$WERCKER_GEMFURY_PUBLISH_GEM_VERSION" ]; then
    fail "could not determine version from the gemspec"
  fi


  # Build the gem
  gem build $WERCKER_GEMFURY_PUBLISH_GEMSPEC
  if [ ! -f "$WERCKER_GEMFURY_PUBLISH_GEM" ]; then
    fail "failed to build '$WERCKER_GEMFURY_PUBLISH_GEM'"
  fi


  # Publish the gem to Gemfury
  curl \
    -F "package=@$WERCKER_GEMFURY_PUBLISH_GEM" \
    https://$WERCKER_GEMFURY_PUBLISH_TOKEN@push.fury.io/$WERCKER_GEMFURY_PUBLISH_ORG/
}

main