package StudentDetails::View::Info;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

StudentDetails::View::Info - TT View for StudentDetails

=head1 DESCRIPTION

TT View for StudentDetails.

=head1 SEE ALSO

L<StudentDetails>

=head1 AUTHOR

aishu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
