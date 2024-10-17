// React
import { createContext } from 'react';

export const FocusContext = createContext<{
  focusContent: () => void;
} | null>(null);
