// React
import { FC, useContext, useState } from 'react';
// Icons
import { IconChevronRight } from '@tabler/icons-react';
// React Router
import { useNavigate } from 'react-router-dom';
// Mantine
import { Box, Collapse, Group, Text, ThemeIcon, UnstyledButton } from '@mantine/core';
// Contexts
import { FocusContext } from '@/contexts';
// Classes
import classes from './NavbarLinksGroup.module.css';

// Interfaces
interface LinksGroupProps {
  icon: FC<any>;
  label: string;
  initiallyOpened?: boolean;
  link?: string;
  links?: { label: string; link: string }[];
}

export function LinksGroup({ icon: Icon, label, initiallyOpened, links, link }: LinksGroupProps) {
  const hasLinks = Array.isArray(links);
  const [opened, setOpened] = useState(initiallyOpened || false);
  const navigate = useNavigate();
  const focusContext = useContext(FocusContext);

  const handleSectionClick = () => {
    if (hasLinks) {
      setOpened((o) => !o);
    } else if (link) {
      navigate(link);
      focusContext?.focusContent();
    }
  };

  const handleSubsectionClick = (event: React.MouseEvent<HTMLAnchorElement>, link: string) => {
    event.preventDefault();
    navigate(link);
    focusContext?.focusContent();
  };

  const items = (hasLinks ? links : []).map((link) => (
    <Text<'a'>
      component="a"
      className={classes.link}
      href={link.link}
      key={link.label}
      onClick={(event) => handleSubsectionClick(event, link.link)}
    >
      {link.label}
    </Text>
  ));

  return (
    <>
      <UnstyledButton
        onClick={handleSectionClick}
        className={classes.control}
        aria-expanded={hasLinks ? opened : undefined}
      >
        <Group>
          <Box className={classes.row}>
            <ThemeIcon variant="light" size={30}>
              <Icon className={classes.icon} />
            </ThemeIcon>
            <Box>{label}</Box>
          </Box>
          {hasLinks && (
            <IconChevronRight
              className={classes.chevron}
              style={{
                transform: opened ? 'rotate(-90deg)' : 'none',
              }}
            />
          )}
        </Group>
      </UnstyledButton>
      {hasLinks ? <Collapse in={opened}>{items}</Collapse> : null}
    </>
  );
}
