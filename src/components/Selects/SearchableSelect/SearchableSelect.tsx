;
// React
import { useEffect, useState } from 'react';
// Mantine
import { CloseButton, Combobox, Input, InputBase, useCombobox } from '@mantine/core';
// Classes
import classes from './SearchableSelect.module.css';


// Interfaces
interface SearchableSelectProps {
  items: { label: string; value: number }[];
  selectedItem: { label: string; value: number } | null;
  setSelectedItem: (item: { label: string; value: number } | null) => void;
  placeholder?: string;
  label?: string;
  required?: boolean;
}

export function SearchableSelect({
  items,
  selectedItem,
  setSelectedItem,
  placeholder,
  label,
  required,
}: SearchableSelectProps) {
  const combobox = useCombobox({
    onDropdownClose: () => combobox.resetSelectedOption(),
  });

  const [search, setSearch] = useState('');

  useEffect(() => {
    if (selectedItem) {
      setSearch(selectedItem.label);
    } else {
      setSearch('');
    }
  }, [selectedItem]);

  const shouldFilterOptions = items.every((item) => item.label !== search);
  const filteredOptions = shouldFilterOptions
    ? items.filter((item) => item.label.toLowerCase().includes(search.toLowerCase().trim()))
    : items;

  const options = filteredOptions.map((item) => (
    <Combobox.Option value={item.label} key={item.value}>
      {item.label}
    </Combobox.Option>
  ));

  return (
    <Input.Wrapper label={label} className={classes.wrapper} required={required}>
      <Combobox
        store={combobox}
        withinPortal={false}
        onOptionSubmit={(val) => {
          const selected = items.find((item) => item.label === val);
          if (selected) {
            setSelectedItem(selected);
            setSearch(selected.label);
            combobox.closeDropdown();
          }
        }}
      >
        <Combobox.Target>
          <InputBase
            classNames={{ input: classes.input }}
            pointer
            rightSection={
              selectedItem ? (
                <CloseButton
                  size="sm"
                  onMouseDown={(event) => {
                    event.preventDefault(); // Prevenir que el combobox cierre automáticamente
                  }}
                  onClick={() => {
                    setSelectedItem(null); // Limpiar la selección
                    setSearch(''); // Limpiar el campo de búsqueda
                    combobox.resetSelectedOption(); // Resetear la opción seleccionada del combobox
                  }}
                  style={{ cursor: 'pointer', zIndex: 1 }}
                  aria-label="Limpiar selección"
                />
              ) : (
                <Combobox.Chevron />
              )
            }
            value={search}
            onChange={(event) => {
              combobox.openDropdown();
              combobox.updateSelectedOptionIndex();
              setSearch(event.currentTarget.value);
            }}
            onClick={() => combobox.openDropdown()}
            onFocus={() => combobox.openDropdown()}
            onBlur={() => {
              combobox.closeDropdown();
              setSearch(selectedItem?.label || '');
            }}
            placeholder={placeholder || 'Search an item...'}
          />
        </Combobox.Target>
        <Combobox.Dropdown>
          <Combobox.Options className={classes.options}>
            {options.length > 0 ? options : <Combobox.Empty>Nothing found</Combobox.Empty>}
          </Combobox.Options>
        </Combobox.Dropdown>
      </Combobox>
    </Input.Wrapper>
  );
}