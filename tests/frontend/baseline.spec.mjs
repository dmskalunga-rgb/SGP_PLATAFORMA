import { test, expect } from '@playwright/test';
test('browser renders baseline using the live API and real PostgreSQL without fatal errors',async({page})=>{
  const errors=[];page.on('pageerror',error=>errors.push(error.message));
  await page.goto('/');
  await expect(page.getByRole('heading',{name:'SGP-DISPO',exact:true})).toBeVisible();
  await expect(page.getByRole('status')).toHaveText('Serviço disponível.');
  await expect(page.getByText('Ainda não existem módulos operacionais disponíveis nesta fundação.')).toBeVisible();
  expect((await page.request.get('/health/ready')).status()).toBe(200);
  expect(errors).toEqual([]);await expect(page.getByRole('button')).toHaveCount(0);
});
test('real upstream outage displays error and functional retry without fabricated data',async({page})=>{
  await page.goto('http://127.0.0.1:4174/');
  await expect(page.getByRole('status')).toHaveText('Serviço indisponível. Tente novamente.');
  await page.getByRole('button',{name:'Tentar novamente'}).click();
  await expect(page.getByRole('status')).toHaveText('Serviço indisponível. Tente novamente.');
});
