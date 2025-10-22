// ---------- Supabase Setup ----------
const SUPABASE_URL = "https://YOUR_PROJECT_ID.supabase.co"; // ← replace with your Supabase URL
const SUPABASE_ANON_KEY = "YOUR_ANON_KEY"; // ← replace with your Supabase anon key

const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ---------- DOM Elements ----------
const lostList = document.getElementById("lost-list");
const foundList = document.getElementById("found-list");
const form = document.getElementById("item-form");

// ---------- Fetch Lost & Found Items ----------
async function fetchItems() {
  try {
    // Lost items
    const { data: lostItems, error: lostError } = await supabase
      .from("lost_items")
      .select("*")
      .eq("status", "active")
      .order("created_at", { ascending: false });

    if (lostError) throw lostError;
    displayItems(lostItems, lostList, "Lost");

    // Found items
    const { data: foundItems, error: foundError } = await supabase
      .from("found_items")
      .select("*")
      .eq("status", "active")
      .order("created_at", { ascending: false });

    if (foundError) throw foundError;
    displayItems(foundItems, foundList, "Found");
  } catch (err) {
    console.error("Error fetching items:", err.message);
  }
}

// ---------- Display Items ----------
function displayItems(items, container, type) {
  container.innerHTML = "";

  if (!items || items.length === 0) {
    container.innerHTML = `<p>No ${type.toLowerCase()} items yet.</p>`;
    return;
  }

  items.forEach((item) => {
    const card = document.createElement("div");
    card.className = "item-card";
    card.innerHTML = `
      <img src="${item.photo_url || "placeholder.jpg"}" alt="${item.title}" class="item-img">
      <h3>${item.title}</h3>
      <p><strong>Category:</strong> ${item.category}</p>
      <p><strong>Location:</strong> ${item.location}</p>
      <p><strong>Date ${type === "Lost" ? "Lost" : "Found"}:</strong> ${item.date_lost || item.date_found}</p>
      <p>${item.description}</p>
      <p><strong>Contact:</strong> ${item.contact_name} (${item.contact_email})</p>
    `;
    container.appendChild(card);
  });
}

// ---------- Add New Item ----------
if (form) {
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    const table = data.type === "lost" ? "lost_items" : "found_items";

    try {
      const { error } = await supabase.from(table).insert([
        {
          user_id: data.user_id, // must match authenticated Supabase user
          title: data.title,
          description: data.description,
          category: data.category,
          location: data.location,
          date_lost: data.type === "lost" ? data.date : null,
          date_found: data.type === "found" ? data.date : null,
          contact_name: data.contact_name,
          contact_email: data.contact_email,
          contact_phone: data.contact_phone,
          photo_url: data.photo_url || null,
        },
      ]);

      if (error) throw error;

      alert(`${data.type} item added successfully!`);
      form.reset();
      fetchItems();
    } catch (err) {
      console.error("Error adding item:", err.message);
      alert("Failed to add item. Check console for details.");
    }
  });
}

// ---------- Initialize ----------
fetchItems();

