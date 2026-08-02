defmodule SambaWeb.Components.Headless.Select do
  @moduledoc """
  Headless **select** (listbox) — a button that opens a single- or multi-select option list
  (Base UI parity). Supports both static `<:option>` slots and dynamic `options` list attribute.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :name, :string, default: nil, doc: "Name for the hidden form input(s)"

  attr :value, :any,
    default: nil,
    doc: "Selected value (string), or a list of values when multiple"

  attr :placeholder, :string,
    default: "Select…",
    doc: "Shown (with data-placeholder) when nothing is selected"

  attr :label, :string,
    default: nil,
    doc: "Accessible label (a <label> wired via aria-labelledby)"

  attr :multiple, :boolean,
    default: false,
    doc: "Allow selecting several options (stays open; submits name[])"

  attr :disabled, :boolean, default: false, doc: "Disable the select (data-disabled)"
  attr :readonly, :boolean, default: false, doc: "Block changing the selection (data-readonly)"

  attr :required, :boolean,
    default: false,
    doc: "Require a selection for form submit (data-required)"

  attr :form, :string, default: nil, doc: "Form id owning the hidden input(s)"
  attr :side, :string, default: "bottom", doc: "Popup side: bottom | top | left | right"
  attr :highlight_on_hover, :boolean, default: true, doc: "Highlight items on pointer hover"
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on selection ({value})"
  attr :on_open_change, :string, default: nil, doc: "LiveView event pushed on open/close ({open})"
  attr :class, :any, default: nil

  # Dynamic options list attribute supporting strings, tuples, or maps
  attr :options, :list, default: [], doc: "List of options for dynamic rendering"

  # Optional per-part class hooks
  attr :label_class, :any, default: nil, doc: "Extra classes for the label part"
  attr :trigger_class, :any, default: nil, doc: "Extra classes for the trigger part"
  attr :value_class, :any, default: nil, doc: "Extra classes for the value part"
  attr :icon_class, :any, default: nil, doc: "Extra classes for the trigger icon part"
  attr :positioner_class, :any, default: nil, doc: "Extra classes for the positioner part"
  attr :popup_class, :any, default: nil, doc: "Extra classes for the popup part"
  attr :group_class, :any, default: nil, doc: "Extra classes for each group part"
  attr :group_label_class, :any, default: nil, doc: "Extra classes for each group-label part"
  attr :item_class, :any, default: nil, doc: "Extra classes for each item part"

  attr :item_indicator_class, :any,
    default: nil,
    doc: "Extra classes for each item-indicator part"

  attr :item_text_class, :any, default: nil, doc: "Extra classes for each item-text part"

  attr :rest, :global

  slot :icon, doc: "Custom trigger icon (replaces the default caret glyph)"
  slot :item_indicator, doc: "Custom selected-item indicator (replaces the default check glyph)"

  slot :option do
    attr :value, :string, required: true
    attr :disabled, :boolean, doc: "Disable just this option"
    attr :group, :string, doc: "Optional group label (consecutive same-group options are grouped)"
    attr :class, :any, doc: "Extra classes for this item part"
    attr :text_class, :any, doc: "Extra classes for this item-text part"
  end

  def select(assigns) do
    # Normalize passed options list into structures compatible with slot rendering
    normalized_dynamic_options =
      Enum.map(assigns.options, fn
        %{value: _} = opt ->
          %{
            value: to_string(opt.value),
            disabled: Map.get(opt, :disabled),
            group: Map.get(opt, :group),
            class: Map.get(opt, :class),
            text_class: Map.get(opt, :text_class),
            inner_block: fn _, _ -> to_string(Map.get(opt, :label, opt.value)) end
          }

        {label, val} ->
          %{
            value: to_string(val),
            disabled: nil,
            group: nil,
            class: nil,
            text_class: nil,
            inner_block: fn _, _ -> to_string(label) end
          }

        val when is_binary(val) or is_atom(val) ->
          %{
            value: to_string(val),
            disabled: nil,
            group: nil,
            class: nil,
            text_class: nil,
            inner_block: fn _, _ -> to_string(val) end
          }
      end)

    all_options = assigns.option ++ normalized_dynamic_options

    values =
      cond do
        assigns.multiple -> List.wrap(assigns.value)
        assigns.value in [nil, ""] -> []
        true -> [assigns.value]
      end

    assigns =
      assign(assigns,
        values: values,
        groups: group_options(all_options),
        selected_opts: Enum.filter(all_options, &(&1.value in values))
      )

    ~H"""
    <div
      id={@id}
      phx-hook="Select"
      data-name={@name}
      data-placeholder={@placeholder}
      data-multiple={@multiple}
      data-disabled={@disabled}
      data-readonly={@readonly}
      data-required={@required}
      data-side={@side}
      data-no-hover={!@highlight_on_hover}
      data-on-change={@on_change}
      data-on-open-change={@on_open_change}
      class={["chelekom-select", @class]}
      {@rest}
    >
      <label
        :if={@label}
        id={"#{@id}-label"}
        data-part="label"
        class={["chelekom-select__label", @label_class]}
      >
        {@label}
      </label>

      <span data-part="value-inputs" class="chelekom-sr-only">
        <%= for v <- @values do %>
          <input
            :if={@name}
            type="hidden"
            name={if @multiple, do: "#{@name}[]", else: @name}
            value={v}
            form={@form}
          />
        <% end %>
        <input
          :if={@name && @values == [] && !@multiple}
          type="hidden"
          name={@name}
          value=""
          form={@form}
        />
      </span>

      <button
        type="button"
        data-part="trigger"
        role="combobox"
        aria-haspopup="listbox"
        aria-controls={"#{@id}-popup"}
        aria-expanded="false"
        aria-labelledby={@label && "#{@id}-label"}
        aria-readonly={@readonly && "true"}
        aria-required={@required && "true"}
        disabled={@disabled}
        data-disabled={@disabled}
        data-readonly={@readonly}
        data-required={@required}
        data-placeholder={@values == []}
        class={["chelekom-select__trigger", @trigger_class]}
      >
        <span
          data-part="value"
          data-placeholder={@values == []}
          class={["chelekom-select__value", @value_class]}
        >
          <%= if @selected_opts == [] do %>
            {@placeholder}
          <% else %>
            <%= for {opt, idx} <- Enum.with_index(@selected_opts) do %>
              <%= if idx > 0 do %>
                ,
              <% end %>
              {render_slot(opt)}
            <% end %>
          <% end %>
        </span>
        <span data-part="icon" aria-hidden="true" class={["chelekom-select__icon", @icon_class]}>
          <%= if @icon != [] do %>
            {render_slot(@icon)}
          <% else %>
            ▾
          <% end %>
        </span>
      </button>

      <div data-part="positioner" class={["chelekom-select__positioner", @positioner_class]}>
        <ul
          id={"#{@id}-popup"}
          data-part="popup"
          role="listbox"
          aria-multiselectable={@multiple && "true"}
          data-closed
          class={["chelekom-select__popup", @popup_class]}
        >
          <%= for {grp, gi} <- Enum.with_index(@groups) do %>
            <%= if grp.label do %>
              <li
                role="group"
                aria-labelledby={"#{@id}-grp-#{gi}"}
                data-part="group"
                class={["chelekom-select__group", @group_class]}
              >
                <span
                  id={"#{@id}-grp-#{gi}"}
                  data-part="group-label"
                  class={["chelekom-select__group-label", @group_label_class]}
                >
                  {grp.label}
                </span>
                <ul role="presentation" class="chelekom-select__group-list">
                  <.option
                    :for={opt <- grp.options}
                    opt={opt}
                    values={@values}
                    item_class={@item_class}
                    item_indicator_class={@item_indicator_class}
                    item_text_class={@item_text_class}
                    item_indicator={@item_indicator}
                  />
                </ul>
              </li>
            <% else %>
              <.option
                :for={opt <- grp.options}
                opt={opt}
                values={@values}
                item_class={@item_class}
                item_indicator_class={@item_indicator_class}
                item_text_class={@item_text_class}
                item_indicator={@item_indicator}
              />
            <% end %>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  attr :opt, :map, required: true
  attr :values, :list, required: true
  attr :item_class, :any, default: nil
  attr :item_indicator_class, :any, default: nil
  attr :item_text_class, :any, default: nil
  attr :item_indicator, :any, default: []

  defp option(assigns) do
    ~H"""
    <li
      role="option"
      data-part="item"
      data-value={@opt.value}
      aria-selected={to_string(@opt.value in @values)}
      data-selected={@opt.value in @values}
      data-disabled={@opt[:disabled]}
      tabindex="-1"
      class={["chelekom-select__option", @item_class, @opt[:class]]}
    >
      <span
        data-part="item-indicator"
        aria-hidden="true"
        class={["chelekom-select__indicator", @item_indicator_class]}
      >
        <%= if @item_indicator != [] do %>
          {render_slot(@item_indicator)}
        <% else %>
          ✓
        <% end %>
      </span>
      <span
        data-part="item-text"
        class={["chelekom-select__text", @item_text_class, @opt[:text_class]]}
      >{render_slot(@opt)}</span>
    </li>
    """
  end

  defp group_options(options) do
    options
    |> Enum.chunk_by(& &1[:group])
    |> Enum.map(fn [first | _] = chunk -> %{label: first[:group], options: chunk} end)
  end
end
