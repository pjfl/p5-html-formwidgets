requires "Class::Accessor" => "0.34";
requires "Class::Load" => "0.22";
requires "HTML::Accessors" => "v0.12.0";
requires "PPI" => "1.218";
requires "PPI::HTML" => "1.08";
requires "Pod::Xhtml" => "1.61";
requires "Try::Tiny" => "0.22";
requires "parent" => "0.228";
requires "perl" => "5.01";

on 'build' => sub {
  requires "Module::Build" => "0.4004";
  requires "Test::Requires" => "0.06";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
