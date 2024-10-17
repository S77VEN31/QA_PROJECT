// React
import { useRef } from 'react';
// Components
import { NavbarNested } from '@components';
// React Router
import { Outlet } from 'react-router-dom';
// Contexts
import { FocusContext } from '@/contexts';
// Classes
import classes from './Dashboard.module.css';

export function DashboardPage() {
  const contentRef = useRef<HTMLDivElement>(null);

  const focusContent = () => {
    if (contentRef.current) {
      contentRef.current.focus();
    }
  };

  return (
    <FocusContext.Provider value={{ focusContent }}>
      <div className={classes.mainLayout}>
        <NavbarNested />
        <div ref={contentRef} tabIndex={-1} className={classes.contentWrapper}>
          <Outlet />
        </div>
      </div>
    </FocusContext.Provider>
  );
}
