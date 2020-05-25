RestRails::Engine.routes.draw do
  get    '/:table_name'            => 'data#index',        as: 'data_index'
  post   '/:table_name'            => 'data#create'

  get    '/:table_name/:id'        => 'data#show',         as: 'data_show'
  patch  '/:table_name/:id'        => 'data#update'
  put  '/:table_name/:id'          => 'data#update'
  delete '/:table_name/:id'        => 'data#destroy',      as: 'data_destroy'

  post   '/:table_name/:id/attach/:attachment_name' => 'data#attach'
  delete '/:table_name/:id/unattach/:attachment_id' => 'data#unattach'

  get    '/:table_name/:id/:column' => 'data#fetch_column'
end
