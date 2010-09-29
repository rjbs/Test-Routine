package inc::BuildDemo;
use Moose;
with(
  'Dist::Zilla::Role::FileMunger',
  'Dist::Zilla::Role::TextTemplate',
);

use namespace::autoclean;

sub munge_file {
  my ($self, $file) = @_;
  return unless $file->name eq 'lib/Test/Routine/Manual/Demo.pm';

  my @demo_files = sort <t/??-*.t>;

  my $demo_text = '';
  for my $demo_file (@demo_files) {
    my $content = do {
      use autodie;
      open my $fh, '<', $demo_file;
      local $/;
      <$fh>;
    };

    $content =~ s{^}{  }mg;

    $demo_text .= "=head2 $demo_file\n\n$content\n\n";
  }

  my $new_content = $self->fill_in_string(
    $file->content,
    {
      demo => $demo_text,
    },
  );

  $file->content($new_content);
}

1;
