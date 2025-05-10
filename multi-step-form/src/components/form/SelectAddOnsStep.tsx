'use client';

import { Box, Button, Checkbox, Group, Stack, Text, Title, Paper } from '@mantine/core';
import { useRouter } from 'next/navigation';
import { useFormStore } from '@/store/formStore';
import classes from '@/styles/SelectAddOnsStep.module.css'; // CSS Module for styling

export default function SelectAddOnsStep() {
  const router = useRouter();
  const addOns = useFormStore((state) => state.addOns);
  const updateAddOn = useFormStore((state) => state.updateAddOn);
  const billing = useFormStore((state) => state.plan.billing);
  const setCurrentStep = useFormStore((state) => state.setCurrentStep);

  const handleAddOnChange = (id: string, checked: boolean) => {
    updateAddOn(id, checked);
  };

  const handleSubmit = () => {
    setCurrentStep(4); // Next step is Summary
    router.push('/form/summary');
  };

  const isYearly = billing === 'yearly';

  return (
    <Box>
      <Title order={2} mb="xs" style={{ color: 'hsl(213, 96%, 18%)', fontWeight: 700 }}>
        Pick add-ons
      </Title>
      <Text mb="lg" style={{ color: 'hsl(231, 11%, 63%)' }}>
        Add-ons help enhance your gaming experience.
      </Text>

      <Stack gap="md">
        {addOns.map((addOn) => (
          <Paper
            key={addOn.id}
            p="md"
            radius="md"
            withBorder
            className={`${classes.addOnCard} ${addOn.selected ? classes.active : ''}`}
            onClick={() => handleAddOnChange(addOn.id, !addOn.selected)} // Allow clicking the whole card
          >
            <Group justify="space-between" wrap="nowrap">
              <Group gap="md" align="center" wrap="nowrap">
                <Checkbox
                  checked={addOn.selected}
                  onChange={(event) => handleAddOnChange(addOn.id, event.currentTarget.checked)}
                  size="md"
                  aria-label={addOn.name}
                />
                <Box>
                  <Text fw={500} style={{ color: 'hsl(213, 96%, 18%)' }}>{addOn.name}</Text>
                  <Text size="sm" style={{ color: 'hsl(231, 11%, 63%)' }}>
                    {/* Placeholder for description - you'll need to add this to AddOnData type and store */}
                    {/* e.g., Access to multiplayer games */}
                  </Text>
                </Box>
              </Group>
              <Text size="sm" style={{ color: 'hsl(243, 100%, 62%)' /* Purple */ }}>
                +${isYearly ? `${addOn.priceYearly}/yr` : `${addOn.priceMonthly}/mo`}
              </Text>
            </Group>
          </Paper>
        ))}
      </Stack>

      <Group justify="space-between" mt="xl">
        <Button variant="subtle" onClick={() => router.push('/form/select-plan')}>
          Go Back
        </Button>
        <Button onClick={handleSubmit} style={{ backgroundColor: 'hsl(213, 96%, 18%)' }}>
          Next Step
        </Button>
      </Group>
    </Box>
  );
} 