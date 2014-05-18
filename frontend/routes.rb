ArchivesSpace::Application.routes.draw do

  match('plugins/oclc' => 'oclc#index', :via => [:get])
  match('plugins/oclc/search' => 'oclc#search', :via => [:get])
  match('plugins/oclc/import' => 'oclc#import', :via => [:post])

end
