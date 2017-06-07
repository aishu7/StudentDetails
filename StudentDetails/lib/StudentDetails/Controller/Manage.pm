package StudentDetails::Controller::Manage;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

StudentDetails::Controller::Manage - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

=item index

Params : NONE

Returns: NONE

Desc   : index helps store the index page and pass it between view and controller during a request

=cut

sub index : Local {

    my ( $self, $c, $save_or_cancel ) = @_;

    $c->stash( template => 'index.tt' );

    if ( $save_or_cancel == 1 ) {
        $c->stash( button_click => 'save' );
    }
    elsif ( $save_or_cancel == 2 ) {
        $c->stash( button_click => 'cancel' );
    }

}

=item manage_data

Params : NONE

Returns : NONE

Desc : manage_data stores the add_details and display_form page and pass it between view and controller corresponding to the button action

=cut

sub manage_data : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->method() eq "POST" && $c->req->param('add') ) {
        $c->stash( template => 'details/add_details.tt' );

    }

    elsif ( $c->req->param('show') ) {
        $c->stash( template => 'display/display_form.tt' );
    }
    elsif ( $c->req->param('display_all'))
{
 $c->visit('display_data');}
}




=item add_data

Params : NONE

Returns : NONE

Desc : add_data stores form details which is entered by user and store into Student database

=cut

sub add_data : Local {
    my ( $self, $c ) = @_;
    my $save_or_cancel;

    #getting all information from the form
    my $first       = $c->req->param('first_name');
    my $last        = $c->req->param('last_name');
    my $gender      = $c->req->param('gender');
    my $dob         = $c->req->param('dob');
    my $contact_num = $c->req->param('num');
    my $address     = $c->req->param('address');
    my $course      = $c->req->param('course');

    #creation of result set for the student database
    my $student_result_set = $c->model('StudentDB::Student');
    if ( $c->req->method() eq "POST" && $c->req->param('save') ) {

        #adding info into student database
        my $result = $student_result_set->create(
            {
                first_name     => "$first",
                last_name      => "$last",
                gender         => "$gender",
                date_of_birth  => "$dob",
                contact_number => "$contact_num",
                address        => "$address",
                course         => "$course",
            }
        );

        $c->log->debug("Student Data Successfully saved");
        $save_or_cancel = 1;
        $c->visit( 'index', [$save_or_cancel] );
    }

    elsif ( $c->req->method() eq "POST" && $c->req->param('cancel') ) {
        $save_or_cancel = 2;
        $c->visit( 'index', [$save_or_cancel] );
        $c->log->debug("Error. Your Data is not Saved");
    }
}

=item display_data

Params : NULL

Returns: NULL	

Desc : display_data is to get values from user and search into student database and result value of search is passed into search_result page 

=cut

sub display_data : Local {
    my ( $self, $c ) = @_;
    my $first          = $c->req->param('first_name');
    my $rs             = $c->model('StudentDB::Student');
   my $student_result;
    if($first)
{
     $student_result = $rs->search(
        {
            first_name => "$first"
        }
    );
}
else
{
 $student_result =$rs->search();
}
    my @search_result;
    while ( my $i = $student_result->next ) {
        push @search_result,
          {
            id          => $i->student_id,
            first_name  => $i->first_name,
            last_name   => $i->last_name,
            gender      => $i->gender,
            dob         => $i->date_of_birth,
            contact_num => $i->contact_number,
            address     => $i->address,
            course      => $i->course
          };
    }

    $c->stash(
        template => 'display/search_result.tt',
        result   => \@search_result
    );
}

sub delete_row : Local {
    my ( $self, $c ) = @_;
    my $delete_student = $c->model('StudentDB::Student')
      ->find( { student_id => $c->req->param('delete') } )->delete();
 $c->response->redirect('http://localhost:3000/manage/display_data');

}

sub select_row : Local {
    my ( $self, $c ) = @_;
   my $student_id = $c->req->param('update');
    my $single_student_data = $c->model('StudentDB::Student')
      ->search( { student_id => $student_id } );
  my %student_result; 
   while(my $i = $single_student_data->next) { 
       %student_result =    (
            id => $i->student_id,
            first_name  => $i->first_name,
            last_name   => $i->last_name,
            gender      => $i->gender,
            dob         => $i->date_of_birth,
            contact_num => $i->contact_number,
            address     => $i->address,
            course      => $i->course
          );
}
$c->stash(template =>'details/add_details_update.tt',
          result => \%student_result);
  
    }

   



sub update_data : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->param('save') ) {
     my $student_update = $c->model('StudentDB::Student')->find({ student_id => $c->req->param('id')})->update(
            {
                first_name  => $c->req->param('first_name'),
                last_name   => $c->req->param('last_name'),
                gender => $c->req->param('gender'),
                date_of_birth         => $c->req->param('dob'),
                contact_number => $c->req->param('num'),
                address     => $c->req->param('address'),
                course      => $c->req->param('course')
            }
        );
    }
$c->visit('index');
}

sub redirect_home_page : Local {
    my ( $self, $c ) = @_;
    $c->visit('index');
}

=encoding utf8

=head1 AUTHOR

aishu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
