use strict;
use warnings;

use StudentDetails;

my $app = StudentDetails->apply_default_middlewares(StudentDetails->psgi_app);
$app;

