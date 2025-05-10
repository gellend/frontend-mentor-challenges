'use client';

import { Box, Button, Group, Stack, Text, Title, Paper, Divider } from '@mantine/core';
import { useRouter } from 'next/navigation';
import { useFormStore } from '@/store/formStore';
import Link from 'next/link';

export default function SummaryStep() {
  const router = useRouter();
  const personalInfo = useFormStore((state) => state.personalInfo);
  const plan = useFormStore((state) => state.plan);
  const addOns = useFormStore((state) => state.addOns);
  const setCurrentStep = useFormStore((state) => state.setCurrentStep);

  const selectedAddOns = addOns.filter(addon => addon.selected);
  const isYearly = plan.billing === 'yearly';

  let totalPrice = plan.price || 0;
  selectedAddOns.forEach(addon => {
    totalPrice += isYearly ? addon.priceYearly : addon.priceMonthly;
  });

  const handleSubmit = () => {
    console.log('Form Submitted:', { personalInfo, plan, addOns: selectedAddOns, totalPrice });
    setCurrentStep(5);
    router.push('/form/thank-you');
  };

  const planName = plan.type ? plan.type.charAt(0).toUpperCase() + plan.type.slice(1) : 'N/A';
  const billingCycleText = isYearly ? 'Yearly' : 'Monthly';
  const billingCycleAbbr = isYearly ? 'yr' : 'mo';

  return (
    <Box>
      <Title order={2} mb="xs" style={{ color: 'hsl(213, 96%, 18%)', fontWeight: 700 }}>
        Finishing up
      </Title>
      <Text mb="lg" style={{ color: 'hsl(231, 11%, 63%)' }}>
        Double-check everything looks OK before confirming.
      </Text>

      <Paper p="md" radius="md" style={{ backgroundColor: 'hsl(218, 100%, 97%)' }}>
        <Stack gap="md">
          <Group justify="space-between" align="flex-start">
            <Box>
              <Text fw={500} style={{ color: 'hsl(213, 96%, 18%)' }}>
                {planName} ({billingCycleText})
              </Text>
              <Link href="/form/select-plan" passHref>
                <Text size="sm" td="underline" style={{ color: 'hsl(231, 11%, 63%)', cursor: 'pointer' }}>
                  Change
                </Text>
              </Link>
            </Box>
            <Text fw={500} style={{ color: 'hsl(213, 96%, 18%)' }}>
              ${plan.price}/{billingCycleAbbr}
            </Text>
          </Group>

          {selectedAddOns.length > 0 && <Divider my="xs" />}

          {selectedAddOns.map(addon => (
            <Group key={addon.id} justify="space-between">
              <Text size="sm" style={{ color: 'hsl(231, 11%, 63%)' }}>{addon.name}</Text>
              <Text size="sm" style={{ color: 'hsl(213, 96%, 18%)' }}>
                +${isYearly ? addon.priceYearly : addon.priceMonthly}/{billingCycleAbbr}
              </Text>
            </Group>
          ))}
        </Stack>
      </Paper>

      <Group justify="space-between" mt="lg" p="md">
        <Text size="sm" style={{ color: 'hsl(231, 11%, 63%)' }}>
          Total (per {isYearly ? 'year' : 'month'})
        </Text>
        <Text size="xl" fw={700} style={{ color: 'hsl(243, 100%, 62%)' }}>
          ${totalPrice}/{billingCycleAbbr}
        </Text>
      </Group>

      <Group justify="space-between" mt="xl">
        <Button variant="subtle" onClick={() => router.push('/form/add-ons')}>
          Go Back
        </Button>
        <Button onClick={handleSubmit} style={{ backgroundColor: 'hsl(243, 100%, 62%)' }}>
          Confirm
        </Button>
      </Group>
    </Box>
  );
} 