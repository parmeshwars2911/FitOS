-- FitOS V1 cloud state.
-- One versioned snapshot per authenticated user keeps the first sync model simple,
-- auditable, and compatible with the app's Codable domain model.

create table if not exists public.fitos_cloud_state (
    user_id uuid primary key references auth.users(id) on delete cascade,
    revision bigint not null default 1 check (revision > 0),
    payload jsonb not null,
    updated_at timestamptz not null default now(),
    constraint fitos_cloud_state_payload_size
        check (octet_length(payload::text) <= 5242880)
);

alter table public.fitos_cloud_state enable row level security;
alter table public.fitos_cloud_state force row level security;

revoke all on table public.fitos_cloud_state from anon;
grant select, insert, update on table public.fitos_cloud_state to authenticated;

create policy "users can read only their FitOS state"
on public.fitos_cloud_state
for select
to authenticated
using (auth.uid() = user_id);

create policy "users can create only their FitOS state"
on public.fitos_cloud_state
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "users can update only their FitOS state"
on public.fitos_cloud_state
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create or replace function public.fitos_pull_state()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
    select jsonb_build_object(
        'revision', revision,
        'payload', payload,
        'updated_at', updated_at
    )
    from public.fitos_cloud_state
    where user_id = auth.uid();
$$;

create or replace function public.fitos_commit_state(
    p_expected_revision bigint,
    p_payload jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_user_id uuid := auth.uid();
    v_row public.fitos_cloud_state%rowtype;
begin
    if v_user_id is null then
        raise exception using errcode = '28000', message = 'authentication_required';
    end if;

    if p_payload is null then
        raise exception using errcode = '22004', message = 'payload_required';
    end if;

    if p_expected_revision is null then
        insert into public.fitos_cloud_state (user_id, revision, payload)
        values (v_user_id, 1, p_payload)
        on conflict (user_id) do nothing
        returning * into v_row;

        if found then
            return jsonb_build_object(
                'revision', v_row.revision,
                'payload', v_row.payload,
                'updated_at', v_row.updated_at
            );
        end if;
    end if;

    select *
    into v_row
    from public.fitos_cloud_state
    where user_id = v_user_id
    for update;

    if not found then
        raise exception using errcode = '40001', message = 'revision_conflict';
    end if;

    if p_expected_revision is null or v_row.revision <> p_expected_revision then
        raise exception using errcode = '40001', message = 'revision_conflict';
    end if;

    update public.fitos_cloud_state
    set revision = revision + 1,
        payload = p_payload,
        updated_at = now()
    where user_id = v_user_id
    returning * into v_row;

    return jsonb_build_object(
        'revision', v_row.revision,
        'payload', v_row.payload,
        'updated_at', v_row.updated_at
    );
end;
$$;

revoke all on function public.fitos_pull_state() from public, anon;
revoke all on function public.fitos_commit_state(bigint, jsonb) from public, anon;
grant execute on function public.fitos_pull_state() to authenticated;
grant execute on function public.fitos_commit_state(bigint, jsonb) to authenticated;
