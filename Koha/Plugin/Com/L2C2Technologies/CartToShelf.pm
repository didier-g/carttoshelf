package Koha::Plugin::Com::L2C2Technologies::CartToShelf;

use Modern::Perl;
use strict;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use C4::Context;
use C4::Auth;

use C4::Items qw/ GetItem GetItemnumberFromBarcode CartToShelf /;
use C4::Log;


## Here we set our plugin version
our $VERSION = "1.0";

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'CartToShelf Plugin',
    author          => 'Indranil Das Gupta (L2C2 Technologies)',
    date_authored   => '2018-12-31',
    date_updated    => "2019-02-01",
    minimum_version => '17.11.00.000',
    version         => $VERSION,
    description     => 'This plugin helps to move scanned items from cart to shelf',
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

sub tool {
    my ( $self, $args ) = @_;

    my $cgi = $self->{'cgi'};

    unless ( $cgi->param('move_to_shelf') ) {
        $self->tool_step1();
    }
    else {
        $self->tool_step2();
    }

}

## This method will be run just before the plugin files are deleted
## when a plugin is uninstalled. It is good practice to clean up
## after ourselves!
sub uninstall() {
    my ( $self, $args ) = @_;

}

## This is the 'upgrade' method. It will be triggered when a newer version of a
## plugin is installed over an existing older version of a plugin
sub upgrade {
    my ( $self, $args ) = @_;

    my $dt = dt_from_string();
    $self->store_data( { last_upgraded => $dt->ymd('-') . ' ' . $dt->hms(':') } );

    return 1;
}

sub tool_step1 {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    my $template = $self->get_template({ file => 'tool-step1.tt' });

    $self->output_html( $template->output() );
}

sub tool_step2 {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    my $template = $self->get_template({ file => 'tool-step2.tt' });

    my $borrowernumber = C4::Context->userenv->{'number'};
	
    my ( @list_of_bad_barcodes, @list_of_non_cart_barcodes );

    my $get_valid_barcode = 0; 
    my $barcode_processed_count = 0;
    my $non_cart_barcodes = 0;
    my $bad_barcode_count = 0;
    my $items_moved_count = 0;

    my $barcode_list = $cgi->param('barcode_list') || undef;

    if ($barcode_list) {
       # $barcode_list is passed as a CR separated list
       my @barcodes_unchecked = split /\n/, $barcode_list;

       foreach my $number (@barcodes_unchecked) {
           $number =~ s/\r$//; # remove any \r character
           $get_valid_barcode = GetItem( undef, $number );
           # check if a valid barcode
           if ( $get_valid_barcode ) {
               if ( $get_valid_barcode->{'location'} eq 'CART' ) {
                  my $item_number = GetItemnumberFromBarcode($number);
                  CartToShelf($item_number);
                  logaction("CATALOGUING", "MODIFY", $item_number, "[CartToShelf Plugin] Changed from 'CART' to '".$get_valid_barcode->{'permanent_location'}."'" );
                  $items_moved_count++;
               } else {
                   push( @list_of_non_cart_barcodes, $number );
                   $non_cart_barcodes++;
               }
           } else {
               push( @list_of_bad_barcodes, $number );
               $bad_barcode_count++
           }
           $barcode_processed_count++;
       }
    }    

    $template->param(
        barcode_processed 		=> $barcode_processed_count,
        non_cart_barcodes		=> $non_cart_barcodes,
        bad_barcode_count		=> $bad_barcode_count,
        items_moved_count		=> $items_moved_count,
        list_of_bad_barcodes		=> \@list_of_bad_barcodes,
        list_of_non_cart_barcodes	=> \@list_of_non_cart_barcodes,
    );

    $self->output_html( $template->output() );
}

1;
