class FbesPlugin::Queries

  def self.all environment
    hostname = environment.top_url
    Hash.map do |key, query|
      "http://#{hostname}/plugin/fbes/queries/#{key}?page=1&per_page=20"
    end
  end

  Hash = {
    :orders_by_month => <<EOQ,
select to_char(created_at,'YYYY-MM') mes, count(*)
  from orders_plugin_orders
  group by mes
  order by mes desc
EOQ

    :enterprises_with_products => <<EOQ,
select a.id, a.enabled as "ativado?", case when a.nickname!='' then a.name||' - '||a.nickname else a.name end nome, 'http://cirandas.net/'||a.identifier site, a.address "endereco", a.contact_phone tel, to_char(a.updated_at, 'dd/mm/yyyy') as "Ultima atualizacaoo", array_to_string(ARRAY (select b.name from products as b where b.profile_id=a.id), ', ') as produtos from profiles as a where a.type='Enterprise' and a.active is true and a.visible is true order by a.updated_at desc
EOQ

    :enterprises_enabled_with_products => <<EOQ,
select a.id, case when a.nickname!='' then a.name||' - '||a.nickname else a.name end nome, 'http://cirandas.net/'||a.identifier site, a.address "endereco", a.contact_phone tel, to_char(a.updated_at, 'dd/mm/yyyy') as "Ultima atualizacao", array_to_string(ARRAY (select b.name from products as b where b.profile_id=a.id), ', ') as produtos from profiles as a where a.type='Enterprise' and a.active is true and a.visible is true and a.enabled is true order by a.updated_at desc
EOQ

    :enterprises_updated_products => <<EOQ,
create temporary table tmp as
  select profile_id, to_char(updated_at,'YYYY-MM') mes, count(*) qtde
    from products
    group by mes, profile_id
    order by mes desc, profile_id;

  select a.mes, a.profile_id, b.name, 'http://cirandas.net/'||b.identifier url, a.qtde
    from tmp a, profiles b
    where a.profile_id=b.id and b.type='Enterprise' and visible=true and active=true
    order by a.mes desc, a.qtde desc
EOQ

    :enterprises_products_ranking => <<EOQ,
create temporary table tmp as
    select profile_id, count(*) qtde from products group by profile_id order by qtde desc;

select a.profile_id, b.name, 'http://cirandas.net/'||b.identifier url, a.qtde from tmp a, profiles b
    where a.profile_id=b.id and b.type='Enterprise' and visible=true and active=true
    order by qtde desc
EOQ

    :enterprises_orders_ranking => <<EOQ,
create temporary table tmp as
    select a.id order_id, a.profile_id, b.name, 'http://cirandas.net/'||b.identifier url, (select sum(i.price) from orders_plugin_items i where i.order_id=a.id) valor_dos_pedidos
        from orders_plugin_orders a, profiles b
        where a.profile_id=b.id and b.type='Enterprise' and b.visible=true and b.active=true;

select t.profile_id, b.name, b.url, t.qtde, t.total_pedidos
    from (select profile_id, count(*) qtde, sum(valor_dos_pedidos) total_pedidos, max(order_id) m
            from tmp
            group by profile_id
        ) t
    join tmp b on b.profile_id=t.profile_id and b.order_id=t.m
    order by t.qtde desc
EOQ

    :enterprises_orders_quantity_by_month => <<EOQ,
create temporary table tmp as
    select a.id order_id, a.profile_id, a.created_at, b.name, 'http://cirandas.net/'||b.identifier url, (select sum(i.price) from orders_plugin_items i where i.order_id=a.id) valor_dos_pedidos
        from orders_plugin_orders a, profiles b
        where a.profile_id=b.id and b.type='Enterprise' and b.visible=true and b.active=true;

select t.mes, t.profile_id, b.name, b.url, t.qtde, t.total_pedidos
    from (select to_char(created_at,'YYYY-MM') mes, profile_id, count(*) qtde, sum(valor_dos_pedidos) total_pedidos, max(order_id) m
            from tmp
            group by mes, profile_id
        ) t
    join tmp b on b.profile_id=t.profile_id and b.order_id=t.m
    order by t.mes desc, t.qtde desc",
EOQ

    :enterprises_quantity_with_orders_by_month => <<EOQ,
create temporary table tmp as
    select a.id order_id, a.profile_id, a.created_at, b.name, 'http://cirandas.net/'||b.identifier url, (select sum(i.price) from orders_plugin_items i where i.order_id=a.id) valor_dos_pedidos
        from orders_plugin_orders a, profiles b
        where a.profile_id=b.id and b.type='Enterprise' and b.visible=true and b.active=true;

select t.mes, count(*) qtde_ees, sum(t.qtde) qtde_pedidos, sum(t.total_pedidos) valor_total_pedidos
    from (select to_char(created_at,'YYYY-MM') mes, profile_id, count(*) qtde, sum(valor_dos_pedidos) total_pedidos, max(order_id) m
                      from tmp
                      group by mes, profile_id
                  ) t
    join tmp b on b.profile_id=t.profile_id and b.order_id=t.m
    group by t.mes
    order by t.mes desc
EOQ

    :users_created_by_month => <<EOQ,
select to_char(created_at, 'YYYY-MM') mes, count(*) qtde
  from profiles
  where type='Person' group by mes
  order by mes desc
EOQ

    :communities_created_by_month => <<EOQ,
select to_char(created_at, 'YYYY-MM') mes, count(*) qtde
  from profiles
  where type='Community'
  group by mes
  order by mes desc
EOQ

    :comments_created_by_month => <<EOQ,
select to_char(created_at, 'YYYY-MM') mes, count(*) qtde
  from comments
  where spam is not true and source_type='Article'
  group by mes
  order by mes desc",
EOQ

    :communities => <<EOQ,
select a.id, a.name nome, 'http://cirandas.net/'||a.identifier site, a.members_count "Qtde integrantes", to_char(a.created_at, 'dd/mm/yyyy') as "Data de criacao" from profiles as a where a.type='Community' and visible is true order by a.created_at desc
EOQ

    :people => <<EOQ,
select a.id, a.name nome, a.nickname apelido, b.email, 'http://cirandas.net/'||a.identifier site, a.address "endereco", a.contact_phone tel, to_char(a.updated_at, 'dd/mm/yyyy') as "Ultima atualizacao" from profiles as a, users as b where a.type='Person' and a.user_id = b.id order by a.updated_at desc
EOQ

    :contents_most_commented => <<EOQ,
select t.source_id, a.name, a.type, a.created_at, t.qtde_comentarios
  from (select source_id, count(*) qtde_comentarios
               from comments
               where spam is not true and source_type='Article'
               group by source_id
           ) t join articles a on a.id=t.source_id
  order by qtde_comentarios desc
EOQ
  }
end