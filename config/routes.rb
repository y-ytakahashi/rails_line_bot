Rails.application.routes.draw do
  get 'task/index'
  get 'task/:id/edit' => 'task#edit', as: "task_edit"
  post 'task/:id/update' => 'task#update', as: "task_update"
  delete 'task/:id/delete' => 'task#delete', as: "task_delete"
  post 'line/bot'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
