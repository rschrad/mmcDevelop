export function getLabel(options, selectedValue) {
    for (let option of options) {
        if (option.value === selectedValue) {
            return option.label;
        }
    }
    return null;
}

export function getFieldValue(options, optionLabel) {
    for (let option of options) {
        if (option.label === optionLabel) {
            return option.value;
        }
    }
    return null;
}