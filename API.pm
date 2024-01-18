package Intellexer::API;

use v5.38;
use strict;
use warnings;
use LWP::UserAgent;
use URI;
use Carp;
use JSON;

my $json = JSON->new()->pretty(1);
my $ua   = LWP::UserAgent->new();
$ua->default_header(
    "cache-control" => "no-cache" );
# sample request:
# http://api.intellexer.com/[GET/POST method]?apikey={YourAPIKey}&options={options}
# api docs:
# https://esapi.intellexer.com/Home/Help

sub new($package, $api_key){
    my $self = {
        'api_key' => $api_key,
        'base'    => 'http://api.intellexer.com/',
    };

    return bless $self, $package;
}

## TopicModeling
sub getTopicsFromUrl($self, $url){
    my $uri_obj = $self->_build_url(
        'getTopicsFromUrl?',
        'url'=> $url
        );
    return $self->_react( $ua->get($uri_obj) );

}

sub getTopicsFromFile($self, $file){
    my $uri_obj = $self->_build_url(
        'getTopicsFromFile?');

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content_Type => 'form-data',
            Content => [ file => [$file] ]
        )
    );
}

sub getTopicsFromText($self, $text){
    my $uri_obj = $self->_build_url(
        'getTopicsFromText?');

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content => $text
        )
    );
}

## Linguistic Processor
sub analyzeText($self, $text, %params){
    my $uri_obj = $self->_build_url(
        'analyzeText?',
        %params
        );
    return $self->_react(
        $ua->post(
            $uri_obj,
            Content => $text
        )
    );
}

## Sentiment Analyzer
sub analyzeSentiments($self, $reviews, %params){
    my $uri_obj = $self->_build_url(
        'analyzeSentiments?',
        %params
        );

    return $self->_react(
        $ua->post(
            $uri_obj,
            'Content-Type' => 'application/json',
            Content => $json->encode($reviews)
        )
    );
}

sub sentimentAnalyzerOntologies($self){
    my $uri_obj = $self->_build_url('sentimentAnalyzerOntologies?');
    return $self->_react( $ua->get($uri_obj) );
}

## Named Entity Recognizer
sub recognizeNe($self, %params){
    my $uri_obj = $self->_build_url(
        'recognizeNe?',
         %params
        );
    return $self->_react( $ua->get($uri_obj) );
}

sub recognizeNeFileContent($self, %params){
    my $uri_obj = $self->_build_url(
        'recognizeNeFileContent?',
        %params
        );

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content_Type => 'multipart/form-data',
            Content => [ file => [$params{fileName}] ]
        )
    );
}
sub recognizeNeText($self){}

## Summarizer
sub summarize_get($self){}
sub summarize_post($self){}
sub summarizeText($self){}
sub summarizeFileContent($self){}

## Multi-Document Summarizer
sub multiUrlSummary($self){}

## Comparator
sub compareText($self){}
sub compareUrls($self){}
sub compareUrlwithFile($self){}
sub compareFiles($self){}

## Clusterizer
sub clusterize($self){}
sub clusterizeText($self){}
sub clusterizeFileContent($self){}

## Natural Language Interface
sub convertQueryToBool($self){}

## Preformator
sub supportedDocumentStructures($self){}
sub supportedDocumentTopics($self){}
sub parse($self){}
sub parseFileContent($self){}

## Language Recognizer
sub recognizeLanguage($self){}

## SpellChecker
sub checkTextSpelling($self){}

## Support functions

# build a URI object with necessary form data
sub _build_url( $self, $endpoint, %form){
    my $url = URI->new( $self->{base}.$endpoint);
    $form{'apikey'} = $self->{api_key};
    $url->query_form(\%form);
    return $url;
}

sub _react($self, $response){
    if ($response->is_success) {
        return $json->decode($response->decoded_content);
    }
    else {
        croak $response->status_line."\n".$response->content;
    }
}


1;
