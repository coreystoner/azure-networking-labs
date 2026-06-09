// =============================================================================
// Azure Networking Labs — Portal
// Progress tracking via localStorage. No server required.
// =============================================================================

const REPO_BASE = 'https://github.com/coreystoner/azure-networking-labs/tree/main';

// completionPattern: regex that matches a valid unlock code for each module.
// Codes are generated at deploy time: ANL-MOD0X-{8-char hex session key}-COMPLETE
// Example: ANL-MOD01-A1B2C3D4-COMPLETE
const MODULES = [
  {
    id: 'mod01',
    num: '01',
    title: 'VNets & Subnets',
    icon: '🌐',
    description: 'Build the foundation of Azure networking. Learn how Virtual Networks and subnets carve out isolated, segmented address spaces for your workloads.',
    topics: [
      'Address spaces & CIDR notation',
      'Subnet segmentation (web / app / data tiers)',
      'Reserved IP addresses in Azure',
      'Azure VNet naming conventions'
    ],
    cost: '~$0.00/hr',
    costClass: 'cost-free',
    completionPattern: /^ANL-MOD01-[A-F0-9]{8}-COMPLETE$/i,
    unlocksId: 'mod02',
    alwaysUnlocked: true,
    path: 'modules/01-vnets-subnets'
  },
  {
    id: 'mod02',
    num: '02',
    title: 'Network Security Groups',
    icon: '🔒',
    description: 'Control inbound and outbound traffic at the subnet and NIC level. Understand rule priorities, default rules, and how to test effective security rules.',
    topics: [
      'NSG rule structure (priority, action, direction)',
      'Default security rules you cannot delete',
      'Subnet vs NIC-level association',
      'Viewing effective security rules'
    ],
    cost: '~$0.00/hr',
    costClass: 'cost-free',
    completionPattern: /^ANL-MOD02-[A-F0-9]{8}-COMPLETE$/i,
    unlocksId: 'mod03',
    unlockedBy: 'mod01',
    path: 'modules/02-nsgs'
  },
  {
    id: 'mod03',
    num: '03',
    title: 'VNet Peering',
    icon: '🔗',
    description: 'Connect two Virtual Networks using peering. Explore hub-and-spoke topology and understand how peering affects routing between VNets.',
    topics: [
      'Hub-and-spoke network topology',
      'Bidirectional peering configuration',
      'Peering states (Initiated, Connected)',
      'Traffic flow across peered VNets'
    ],
    cost: '~$0.00/hr',
    costClass: 'cost-free',
    completionPattern: /^ANL-MOD03-[A-F0-9]{8}-COMPLETE$/i,
    unlocksId: 'mod04',
    unlockedBy: 'mod02',
    path: 'modules/03-peering'
  },
  {
    id: 'mod04',
    num: '04',
    title: 'Routing & UDRs',
    icon: '🗺️',
    description: 'Take control of traffic flow with User Defined Routes. Override Azure\'s default system routes to direct traffic through network appliances or specific paths.',
    topics: [
      'Azure system routes vs user-defined routes',
      'Next-hop types (Internet, VirtualAppliance, None)',
      'Route table association with subnets',
      'BGP route propagation'
    ],
    cost: '~$0.00/hr',
    costClass: 'cost-free',
    completionPattern: /^ANL-MOD04-[A-F0-9]{8}-COMPLETE$/i,
    unlocksId: 'mod05',
    unlockedBy: 'mod03',
    path: 'modules/04-routing-udrs'
  },
  {
    id: 'mod05',
    num: '05',
    title: 'Azure Firewall',
    icon: '🔥',
    description: 'Deploy a cloud-native stateful firewall in your hub VNet. Configure network rules, application rules, and DNAT to control all traffic centrally.',
    topics: [
      'Azure Firewall architecture & SKUs',
      'Network rules vs application rules vs DNAT rules',
      'Firewall policies (Policy vs classic rules)',
      'Forced tunneling through the firewall'
    ],
    cost: '~$1.50/hr',
    costClass: 'cost-medium',
    completionPattern: /^ANL-MOD05-[A-F0-9]{8}-COMPLETE$/i,
    unlockedBy: 'mod04',
    path: 'modules/05-azure-firewall'
  },
  {
    id: 'mod06',
    num: '06',
    title: 'Fault Lab: NSG',
    icon: '🔍',
    description: 'A web application can\'t receive traffic despite having an \'allow\' NSG rule. Diagnose and fix the misconfiguration to restore connectivity.',
    topics: [
      '⚠️ Broken environment — find the fault',
      'NSG rule priority conflicts',
      'Using Effective Security Rules for diagnosis',
      '3-tier hint system available'
    ],
    cost: '~$0.10/hr',
    costClass: 'cost-low',
    completionPattern: /^ANL-MOD06-[A-F0-9]{8}-COMPLETE$/i,
    unlocksId: 'mod07',
    unlockedBy: 'mod04',
    path: 'modules/06-fault-nsg'
  },
  {
    id: 'mod07',
    num: '07',
    title: 'Fault Lab: Routing',
    icon: '🔍',
    description: 'A VM in the web subnet has lost internet connectivity. A route table is attached — but something is wrong. Find the problem and restore outbound traffic.',
    topics: [
      '⚠️ Broken environment — find the fault',
      'Route table misconfiguration diagnosis',
      'Using Azure Network Watcher next hop',
      '3-tier hint system available'
    ],
    cost: '~$0.10/hr',
    costClass: 'cost-low',
    completionPattern: /^ANL-MOD07-[A-F0-9]{8}-COMPLETE$/i,
    unlockedBy: 'mod06',
    path: 'modules/07-fault-routing'
  }
];

// ---------------------------------------------------------------------------
// State management
// ---------------------------------------------------------------------------
const STORAGE_KEY = 'anlProgress';

function loadProgress() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}');
  } catch {
    return {};
  }
}

function saveProgress(progress) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
}

function isUnlocked(moduleId, progress) {
  const mod = MODULES.find(m => m.id === moduleId);
  if (!mod) return false;
  if (mod.alwaysUnlocked) return true;
  return mod.unlockedBy ? progress[mod.unlockedBy] === true : false;
}

// ---------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------
function render() {
  const progress = loadProgress();
  const completed = Object.values(progress).filter(Boolean).length;
  const total = MODULES.length;

  document.getElementById('progress-text').textContent = `${completed} / ${total} complete`;
  document.getElementById('progress-fill').style.width = `${(completed / total) * 100}%`;

  const grid = document.getElementById('module-grid');
  grid.innerHTML = MODULES.map(mod => renderCard(mod, progress)).join('');
}

function renderCard(mod, progress) {
  const completed = progress[mod.id] === true;
  const unlocked = isUnlocked(mod.id, progress);
  const locked = !unlocked;

  let statusClass = locked ? 'locked' : (completed ? 'completed' : 'available');
  let badgeClass = locked ? 'badge-locked' : (completed ? 'badge-completed' : 'badge-available');
  let badgeText = locked ? '🔒 Locked' : (completed ? '✅ Completed' : '▶ Available');

  const actions = locked
    ? `<button class="btn-secondary" disabled style="opacity:0.5;cursor:not-allowed">🔒 Locked</button>`
    : completed
      ? `<a href="${REPO_BASE}/${mod.path}" target="_blank" rel="noopener" class="btn-secondary">View Module ↗</a>
         <button class="btn-success">✅ Complete</button>`
      : `<a href="${REPO_BASE}/${mod.path}" target="_blank" rel="noopener" class="btn-secondary">View Module ↗</a>
         <button class="btn-primary" onclick="openModal('${mod.id}')">Enter Code →</button>`;

  return `
  <div class="module-card ${statusClass}">
    <div class="card-header">
      <div class="card-meta">
        <span class="module-number">Module ${mod.num}</span>
        <span class="module-title">${mod.title}</span>
      </div>
      <span class="card-icon">${mod.icon}</span>
    </div>
    <span class="card-status-badge ${badgeClass}">${badgeText}</span>
    <p class="card-description">${mod.description}</p>
    <ul class="card-topics">
      ${mod.topics.map(t => `<li>${t}</li>`).join('')}
    </ul>
    <div class="card-footer">
      <span class="cost-badge ${mod.costClass}">${mod.cost}</span>
      <div class="card-actions">${actions}</div>
    </div>
  </div>`;
}

// ---------------------------------------------------------------------------
// Modal
// ---------------------------------------------------------------------------
let activeModuleId = null;

function openModal(moduleId) {
  const mod = MODULES.find(m => m.id === moduleId);
  if (!mod) return;
  activeModuleId = moduleId;

  document.getElementById('modal-title').textContent = `Module ${mod.num}: Enter Unlock Code`;
  document.getElementById('modal-description').innerHTML =
    `Run <code>validate.ps1</code> in the <code>${mod.path}</code> folder. ` +
    `If all checks pass, it will print your unique unlock code. Copy and paste it below.`;
  document.getElementById('token-input').value = '';
  document.getElementById('token-feedback').textContent = '';
  document.getElementById('token-feedback').className = 'token-feedback';
  document.getElementById('modal-overlay').classList.add('active');
  setTimeout(() => document.getElementById('token-input').focus(), 100);
}

function closeModal() {
  document.getElementById('modal-overlay').classList.remove('active');
  activeModuleId = null;
}

function submitToken() {
  if (!activeModuleId) return;
  const mod = MODULES.find(m => m.id === activeModuleId);
  const input = document.getElementById('token-input').value.trim().toUpperCase();
  const feedback = document.getElementById('token-feedback');

  if (!input) {
    feedback.textContent = 'Please enter a code.';
    feedback.className = 'token-feedback error';
    return;
  }

  if (!mod.completionPattern.test(input)) {
    feedback.textContent = '❌ Code not recognised. Check validate.ps1 output for the exact code.';
    feedback.className = 'token-feedback error';
    return;
  }

  // Success
  const progress = loadProgress();
  progress[mod.id] = true;
  saveProgress(progress);

  feedback.textContent = '🎉 Correct! Module complete!';
  feedback.className = 'token-feedback success';

  setTimeout(() => {
    closeModal();
    render();
  }, 1200);
}

// ---------------------------------------------------------------------------
// Reset
// ---------------------------------------------------------------------------
function confirmReset() {
  if (confirm('Reset all progress? This cannot be undone.')) {
    localStorage.removeItem(STORAGE_KEY);
    render();
  }
}

// ---------------------------------------------------------------------------
// Init
// ---------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', render);
