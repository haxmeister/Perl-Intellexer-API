package Intellexer::API;

use v5.38;
use strict;
use warnings;
use LWP::UserAgent;
use Path::Tiny;
use URI;
use Carp;
use JSON;

my $json = JSON->new()->pretty(1);
my $ua   = LWP::UserAgent->new();
# $ua->default_header(
#     "cache-control" => "no-cache" );
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
            Content => [ path($file)->basename =>[$file] ],
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
            Content => $text,
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

sub recognizeNeFileContent($self, $file, %params){

    my $uri_obj= $self->_build_url(
        'recognizeNeFileContent?',
        %params
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content_Type => 'multipart/form-data',
            Content => [file => [$file,] ],
        )
    );
}

sub recognizeNeText($self, $text, %params){
    my $uri_obj = $self->_build_url(
        'recognizeNeText?',
        %params
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content => $text
        )
    );
}

## Summarizer
sub summarize($self, $url, %params){
    my $uri_obj = $self->_build_url(
        'summarize?',
        'url'=> $url,
        %params,
        );
    return $self->_react( $ua->get($uri_obj) );
}

sub summarizeText($self, $text, %params){
    my $uri_obj = $self->_build_url(
        'summarizeText?',
        %params,
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content => $text,
        )
    );
}

sub summarizeFileContent($self, $file, %params){

    my $uri_obj= $self->_build_url(
        'summarizeFileContent?',
        'filename' => path($file)->basename,
        %params
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            Content_Type => 'multipart/form-data',
            Content => [path($file)->basename => [$file,] ],
        )
    );
}

## Multi-Document Summarizer
sub multiUrlSummary($self, $url_list, %params){
    my $uri_obj = $self->_build_url(
        'multiUrlSummary?',
        %params,
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            'content-type' => 'application/json',
            Content => $json->encode($url_list),
        )
    );

}

## Comparator
sub compareText($self, $text1, $text2, %params){
    my $uri_obj = $self->_build_url(
        'compareText?',
        %params,
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            'content-type' => 'application/json',
            Content => $json->encode({'text1' => $text1, 'text2' => $text2}),
        )
    );
}

sub compareUrls($self, $url1, $url2, %params){
    my $uri_obj = $self->_build_url(
        'compareUrls?',
        'url1' => $url1,
        'url2' => $url2,
        %params,
    );

    return $self->_react(
        $ua->get(
            $uri_obj,
            'content-type' => 'application/json',
        )
    );

}

sub compareUrlwithFile($self, $url, $file, %params){
    my $uri_obj = $self->_build_url(
        'compareUrlwithFile?',
        'url' => $url,
        'filename' => path($file)->basename,
        %params,
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            'content-type' => 'multipart/form-data',
            Content => [path($file)->basename => [$file,] ],
        )
    );
}

sub compareFiles($self, $file1, $file2){
    my $size = -s $file1;
    my $size2 = -s $file2;
    say "file1: $size";
    say "file2: $size2";
    my $uri_obj = $self->_build_url(
        'compareFiles?',
        'filename1' => path($file1)->basename,
        'filename2' => path($file2)->basename,
        'firstFileSize' => $size,
    );

    return $self->_react(
        $ua->post(
            $uri_obj,
            'content-type' => 'multipart/form-data',
            Content => [ path($file1)->basename =>[$file1],
                         path($file2)->basename =>[$file2] ],
        )
    );
}

## Clusterizer
sub clusterize($self, $url, %params){

}

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
    return $url->as_string;
    #return $url;
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
