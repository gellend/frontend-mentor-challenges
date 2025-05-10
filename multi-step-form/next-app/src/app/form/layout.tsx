export default function FormLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <section>
      {/* Sidebar or common layout elements for the form can be placed here */}
      <h1>Multi-Step Form</h1>
      <div style={{ display: 'flex' }}>
        <aside style={{ width: '200px', borderRight: '1px solid #ccc', paddingRight: '20px', marginRight: '20px' }}>
          <p>Step Indicators:</p>
          <ul>
            <li>Step 1: Your Info</li>
            <li>Step 2: Select Plan</li>
            <li>Step 3: Add-ons</li>
            <li>Step 4: Summary</li>
          </ul>
        </aside>
        <main>
          {children}
        </main>
      </div>
    </section>
  );
} 