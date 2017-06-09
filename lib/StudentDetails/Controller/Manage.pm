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

Params : Save_or_cancel

Returns: NONE

Desc   : index helps store the index page and pass it between view and controller during a request

=cut

sub index : Local {

    my ( $self, $c ) = @_;

    $c->stash( template => 'index.tt' );

}

=item student_form

Params : NONE

Returns : NONE

Desc : student_form is to display the form for the students to enter details

=cut

sub student_form : Local {
    my ( $self, $c ) = @_;

    $c->stash( template => 'details/add_details.tt' );

}

=item display_individual_data

Params : NONE

Returns : NONE

Desc : display_individual_data is to display the  search form,in that student can search according to their firstname

=cut

sub display_individual_data : Local {
    my ( $self, $c ) = @_;
    $c->stash( template => 'display/display_form.tt' );
}

=item display_all_data

Params : NONE

Returns : NONE

Desc : display_all_data is to display all the details of student

=cut

sub display_all_data : Local {

    my ( $self, $c ) = @_;
    $c->visit('display_data');
}

=item add_data

Params : NONE

Returns : NONE

Desc : add_data stores form details which is entered by user and store into Student database

=cut

sub add_data : Local {
    my ( $self, $c ) = @_;

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

        my $student_data = {
            first_name     => "$first",
            last_name      => "$last",
            gender         => "$gender",
            date_of_birth  => "$dob",
            contact_number => "$contact_num",
            address        => "$address",
            course         => "$course",
        };

        if ( $c->req->param('id') ) {
            my $student_result_set =
              $c->model('StudentDB::Student')
              ->find( { student_id => $c->req->param('id') } )
              ->update($student_data);
            $c->log->debug("Student Data Successfully Updated");

        }

        else {
            #adding info into student database
            my $result = $student_result_set->create($student_data);

            $c->log->debug("Student Data Successfully Saved");
        }

        $c->visit('index');
    }
}

=item cancel_data

Params : NONE

Returns : NONE

Desc : cancel_data is to cancel the form of student details

=cut

sub cancel_data : Local {
    my ( $self, $c ) = @_;
    $c->visit('index');
    $c->log->debug("Error. Your Data is not Saved");
}

=item display_data

Params : NULL

Returns: NULL	

Desc : display_data is to get values from user and search into student database and result value of search is passed into search_result page 

=cut

sub display_data : Local {
    my ( $self, $c, $first_name ) = @_;
    my $first = $first_name | $c->req->param('first_name');
    my $rs    = $c->model('StudentDB::Student');
    my $student_result;
    if ($first) {
        $student_result = $rs->search(
            {
                first_name => "$first"
            }
        );
        $c->stash( first_name => "$first" );
    }
    else {
        $student_result = $rs->search();
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

=item delete_row

Params : NULL

Returns: NULL   

Desc : delete_row is to delete values from database corresponding to the row which the user selects to delete

=cut

sub delete_row : Local {
    my ( $self, $c ) = @_;
    my $delete_student = $c->model('StudentDB::Student')
      ->find( { student_id => $c->req->param('delete') } )->delete();
    my $first_name = $c->req->param('first_name');
    $c->response->redirect(
        $c->uri_for( "/manage/display_data", $first_name ) );

}

=item select_row

Params : NULL

Returns: NULL   

Desc : select_row is to select the row which the user selects the row for updating.

=cut

sub select_row : Local {
    my ( $self, $c ) = @_;
    my $student_id = $c->req->param('update');
    my $single_student_data =
      $c->model('StudentDB::Student')->search( { student_id => $student_id } );
    my %student_result;
    while ( my $i = $single_student_data->next ) {
        %student_result = (
            id          => $i->student_id,
            first_name  => $i->first_name,
            last_name   => $i->last_name,
            gender      => $i->gender,
            dob         => $i->date_of_birth,
            contact_num => $i->contact_number,
            address     => $i->address,
            course      => $i->course
        );
    }
    $c->stash(
        template => 'details/add_details.tt',
        result   => \%student_result
    );

}

=item redirect_home_page

Params : NULL

Returns: NULL   

Desc : redirect_home_page is to go back to home page when the user sets back button 

=cut

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
